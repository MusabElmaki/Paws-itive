'use strict';
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue: F, Timestamp} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');
const {getStorage} = require('firebase-admin/storage');
const {createHash} = require('node:crypto');
const {onCall, onRequest, HttpsError} = require('firebase-functions/v2/https');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {defineSecret, defineString} = require('firebase-functions/params');
const Stripe = require('stripe');
const {money, discountFor, transition, periodKeys, coordinates} = require('./policy');
initializeApp();
const db = getFirestore();
const region = 'asia-southeast1';
const stripeKey = defineSecret('STRIPE_SECRET_KEY');
const webhookKey = defineSecret('STRIPE_WEBHOOK_SECRET');
const returnUrl = defineString('PAYMENT_RETURN_URL');
const ref = (collection, id) => db.collection(collection).doc(id);
const stamp = () => F.serverTimestamp();
function fail(message, code = 'failed-precondition') { throw new HttpsError(code, message); }
function id(value) { if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(value)) fail('Invalid record identifier.', 'invalid-argument'); return value; }
function text(value, max = 2000) { if (typeof value !== 'string' || !value.trim() || value.length > max) fail('Missing or invalid text.', 'invalid-argument'); return value.trim(); }
async function verifyUpload(path, receipt = false) {
  let metadata;
  try { [metadata] = await getStorage().bucket().file(path).getMetadata(); }
  catch (_) { fail('Upload is incomplete. Please retry.'); }
  const types = receipt ? ['image/jpeg', 'image/png', 'application/pdf'] : ['image/jpeg'];
  if (!types.includes(metadata.contentType) || Number(metadata.size) > (receipt ? 5 : 1) * 1024 * 1024) fail('Invalid uploaded file.');
}
const callable = (fn, options = {}) => onCall({region, ...options}, async request => {
  try { return await fn(request); } catch (e) {
    if (e instanceof HttpsError) throw e;
    console.error(e);
    throw new HttpsError('internal', 'The operation could not be completed. Please retry.');
  }
});
async function actor(request, staff = false, admin = false) {
  if (!request.auth) fail('Sign in first.', 'unauthenticated');
  const uid = request.auth.uid;
  const p = (await ref('users', uid).get()).data();
  if (!p || p.isSuspended || p.status === 'suspended') fail('Account is unavailable.', 'permission-denied');
  if (!request.auth.token.email_verified) fail('Verify your email before continuing.', 'permission-denied');
  if (admin && p.role !== 'admin') fail('Administrator access required.', 'permission-denied');
  if (staff && p.role !== 'admin' && !(p.role === 'volunteer' && p.isApprovedVolunteer && p.status === 'active')) fail('Approved volunteer access required.', 'permission-denied');
  return {...p, uid};
}
function notification(tx, key, title, body, targetUserId = null, audience = 'admins', reportId = null) {
  tx.set(ref('notifications', key), {title, body, targetUserId, audience, reportId, createdAt: stamp()});
}
// Read before any transaction writes. Event IDs make all rewards retry-safe.
async function prepareReward(tx, uid, eventId, points, closed = 0) {
  if (!uid) return () => {};
  const event = ref('reward_events', eventId), user = ref('users', uid), board = ref('leaderboard', uid);
  const [e, u, b] = await tx.getAll(event, user, board);
  if (e.exists || !u.exists) return () => {};
  const p = u.data(), old = b.data() || {}, periods = periodKeys();
  return () => {
  tx.create(event, {userId: uid, points, createdAt: stamp()});
  tx.update(user, {points: F.increment(points)});
  tx.set(board, {name: p.fullName, points: Number(p.points || 0) + points,
    week: periods.week, month: periods.month,
    weeklyPoints: (old.week === periods.week ? old.weeklyPoints || 0 : 0) + points,
    monthlyPoints: (old.month === periods.month ? old.monthlyPoints || 0 : 0) + points,
    casesClosed: (old.casesClosed || 0) + closed, lastUpdated: stamp()}, {merge: true});
  };
}

exports.recoverProfile = callable(async r => {
  if (!r.auth) fail('Sign in first.', 'unauthenticated');
  await db.runTransaction(async tx => {
    const target = ref('users', r.auth.uid);
    if ((await tx.get(target)).exists) return;
    tx.create(target, {email: r.auth.token.email || '', fullName: text(r.data.fullName, 100), role: 'user', status: 'active',
      points: 0, isApprovedVolunteer: false, isSuspended: false, createdAt: stamp()});
  });
  return {ok: true};
});

exports.submitReport = callable(async r => {
  const a = await actor(r), d = r.data, reportId = id(d.requestId);
  const location = text(d.locationName, 200), description = String(d.description || '').slice(0, 2000);
  const coords = coordinates(d.latitude, d.longitude);
  const condition = text(d.reportedCondition, 40);
  if (!['Healthy', 'Sick', 'Injured', 'Critical', 'Needs feeding', 'Other'].includes(condition)) fail('Invalid condition.');
  const photoPath = text(d.photoPath, 300);
  if (photoPath !== `reports/${a.uid}/${reportId}/photo.jpg`) fail('Invalid photo path.');
  await verifyUpload(photoPath);
  const signature = d.imageSignature;
  if (!Array.isArray(signature) || signature.length !== 128 || signature.some(v => !Number.isFinite(v))) fail('Invalid image signature.');
  const report = ref('reports', reportId), cat = ref('cats', reportId);
  await db.runTransaction(async tx => {
    const previous = await tx.get(report);
    if (previous.exists) { if (previous.data().reporterId !== a.uid) fail('Identifier already in use.'); return; }
    const candidate = d.candidateCatId ? id(d.candidateCatId) : null;
    if (candidate && !(await tx.get(ref('cats', candidate))).exists) fail('Suggested cat no longer exists. Retry matching.');
    const quota = ref('report_quotas', `${a.uid}_${new Date().toISOString().slice(0,10)}`);
    const used = (await tx.get(quota)).data()?.count || 0;
    if (used >= 20) fail('Daily reporting limit reached. Contact a volunteer for urgent assistance.', 'resource-exhausted');
    // No reward for unreviewed reports: prevents report spam earning discounts.
    const health = {Healthy: 'healthy', Sick: 'sick', Injured: 'injured', Critical: 'critical'}[condition] || 'unknown';
    tx.create(cat, {name: String(d.catName || '').slice(0, 100), photoUrls: [photoPath], currentLocationName: location,
      ...coords, healthStatus: health, classification: 'stray', currentStatus: candidate ? 'underReview' : 'reported',
      imageSignature: signature, lastUpdated: stamp(), createdBy: a.uid});
    tx.create(report, {reporterId: a.uid, reporterName: a.fullName, catId: cat.id, originalCatId: cat.id,
      catName: String(d.catName || '').slice(0, 100), locationName: location, description, ...coords,
      photoUrl: photoPath, imageSignature: signature, reportedCondition: condition,
      status: candidate ? 'underReview' : 'reported', assignedVolunteerId: null,
      candidateCatId: candidate, duplicateStatus: candidate ? 'pending' : 'none',
      urgency: condition === 'Critical' || condition === 'Injured' ? 'urgent' : 'normal', escalated: false,
      responseDueAt: Timestamp.fromMillis(Date.now() + (condition === 'Critical' ? 1800000 : 7200000)),
      createdAt: stamp(), updatedAt: stamp()});
    tx.set(quota, {count: used + 1});
    tx.create(cat.collection('timeline').doc(reportId), {kind: 'sighting', note: description || condition, photoPath,
      actorId: a.uid, actorName: a.fullName, reportId, createdAt: stamp()});
    notification(tx, `report_${reportId}`, 'New cat report', `${condition}: ${location}`, null, 'volunteers', reportId);
  });
  return {reportId, catId: cat.id};
});

exports.changeCase = callable(async r => {
  const a = await actor(r, true), d = r.data, report = ref('reports', id(d.reportId));
  await db.runTransaction(async tx => {
    const snap = await tx.get(report); if (!snap.exists) fail('Report not found.');
    const old = snap.data(); if (old.archived) fail('Report is archived.');
    const volunteerId = d.volunteerId ? id(d.volunteerId) : old.assignedVolunteerId;
    const next = d.volunteerId ? 'beingAssisted' : text(d.status, 30);
    if (old.status === next && old.assignedVolunteerId === volunteerId) return;
    if (d.volunteerId) {
      if (a.role !== 'admin' && volunteerId !== a.uid) fail('You may only claim a case for yourself.', 'permission-denied');
      if (old.assignedVolunteerId && old.assignedVolunteerId !== volunteerId && a.role !== 'admin') fail('Another volunteer has already accepted this case.', 'already-exists');
      const v = (await tx.get(ref('users', volunteerId))).data();
      if (!v || v.isSuspended || v.status !== 'active' || !(v.role === 'admin' || (v.role === 'volunteer' && v.isApprovedVolunteer))) fail('Choose an active approved volunteer.');
    } else if (a.role !== 'admin' && old.assignedVolunteerId !== a.uid) fail('Only the assigned volunteer can update this case.', 'permission-denied');
    if (!(d.volunteerId && old.status === 'beingAssisted') && !transition(old.status, next)) fail('That case transition is not allowed.');
    const cat = ref('cats', old.catId); if (!(await tx.get(cat)).exists) fail('Cat profile is missing.');
    const related = await tx.get(db.collection('reports').where('catId', '==', old.catId));
    const statuses = related.docs.filter(d => !d.data().archived).map(d => d.id === report.id ? next : d.data().status);
    const currentStatus = ['beingAssisted', 'underReview', 'reported'].find(s => statuses.includes(s)) || 'resolved';
    const eventId = `${report.id}_${next}`;
    const grant = next === 'resolved' ? await prepareReward(tx, volunteerId, eventId, 30, 1)
      : next === 'beingAssisted' ? await prepareReward(tx, volunteerId, eventId, 10) : () => {};
    // Report credit is granted only after staff review; no self-awarded report points.
    const reporterGrant = next === 'beingAssisted' && old.reporterId !== volunteerId
      ? await prepareReward(tx, old.reporterId, `${report.id}_reviewed`, 15) : () => {};
    grant(); reporterGrant();
    tx.update(report, {status: next, assignedVolunteerId: volunteerId || null, updatedAt: stamp()});
    // This is the latest case event, not a replacement cat profile.
    tx.update(cat, {currentStatus, lastUpdated: stamp()});
    tx.set(cat.collection('timeline').doc(eventId), {kind: 'case', note: next, reportId: report.id, actorId: a.uid, actorName: a.fullName, createdAt: stamp()});
    notification(tx, `${eventId}_reporter`, 'Case updated', `Your report is now ${next}.`, old.reporterId, 'personal', report.id);
    if (volunteerId) notification(tx, `${eventId}_volunteer`, 'Case updated', `${old.locationName}: ${next}`, volunteerId, 'personal', report.id);
  });
  return {ok: true};
});

exports.reviewDuplicate = callable(async r => {
  const a = await actor(r, true), report = ref('reports', id(r.data.reportId)), decision = r.data.decision;
  if (!['link', 'reject', 'undo'].includes(decision)) fail('Invalid review decision.');
  await db.runTransaction(async tx => {
    const s = await tx.get(report); if (!s.exists) fail('Report not found.'); const d = s.data();
    if (decision === 'undo' ? d.duplicateStatus !== 'linked' : d.duplicateStatus !== 'pending') fail('This suggestion has already been reviewed.');
    const destination = decision === 'link' ? d.candidateCatId : d.originalCatId;
    if (!destination || !(await tx.get(ref('cats', destination))).exists) fail('Cat profile not found.');
    const log = ref('audit_log', db.collection('audit_log').doc().id);
    tx.update(report, {catId: destination, duplicateStatus: decision === 'link' ? 'linked' : 'rejected', updatedAt: stamp()});
    // Both cat records and their original care histories remain intact for undo.
    tx.update(ref('cats', d.originalCatId), {linkedTo: decision === 'link' ? destination : null, lastUpdated: stamp()});
    const sighting = ref('cats', d.candidateCatId).collection('timeline').doc(`linked_${report.id}`);
    if (decision === 'link') tx.set(sighting, {kind: 'sighting', note: d.description || d.reportedCondition, reportId: report.id,
      photoPath: d.photoUrl, actorId: a.uid, actorName: a.fullName, createdAt: stamp()});
    if (decision === 'undo') tx.delete(sighting);
    tx.create(log, {action: `duplicate_${decision}`, reportId: report.id, from: d.catId, to: destination, actorId: a.uid, createdAt: stamp()});
  });
  return {ok: true};
});

exports.addCareEntry = callable(async r => {
  const a = await actor(r, true), d = r.data, cat = ref('cats', id(d.catId)), entry = cat.collection('timeline').doc(id(d.requestId));
  if (!['feeding', 'medical', 'note'].includes(d.kind)) fail('Invalid care entry.');
  const note = text(d.note);
  await db.runTransaction(async tx => {
    const [c, e] = await tx.getAll(cat, entry); if (!c.exists) fail('Cat not found.'); if (e.exists) return;
    tx.create(entry, {kind: d.kind, note, actorId: a.uid, actorName: a.fullName, createdAt: stamp()});
    tx.update(cat, {lastUpdated: stamp()});
  }); return {ok: true};
});

exports.manageUser = callable(async r => {
  const a = await actor(r, false, true), uid = id(r.data.uid), d = r.data;
  if (uid === a.uid) fail('Ask another administrator to change your privileges.');
  if (!['user', 'volunteer', 'admin'].includes(d.role)) fail('Invalid role.');
  const batch = db.batch();
  batch.update(ref('users', uid), {role: d.role, isApprovedVolunteer: d.role !== 'user', isSuspended: d.suspended === true,
    status: d.suspended ? 'suspended' : 'active'});
  batch.set(ref('volunteers', uid), {userId: uid, approvalStatus: d.role === 'volunteer' ? 'approved' : 'inactive'}, {merge: true});
  batch.create(db.collection('audit_log').doc(), {action: 'manage_user', userId: uid, actorId: a.uid, role: d.role, suspended: d.suspended === true, createdAt: stamp()});
  await batch.commit(); return {ok: true};
});

exports.archiveRecord = callable(async r => {
  const a = await actor(r, false, true), collection = r.data.collection;
  if (!['reports', 'cats', 'fundraising'].includes(collection)) fail('Cannot archive this collection.');
  const batch = db.batch();
  batch.update(ref(collection, id(r.data.id)), {archived: true, ...(collection === 'fundraising' ? {active: false} : {})});
  batch.create(db.collection('audit_log').doc(), {action: 'archive', collection, recordId: r.data.id, actorId: a.uid, createdAt: stamp()});
  await batch.commit(); return {ok: true};
});

exports.submitManualDonation = callable(async r => {
  const a = await actor(r), d = r.data, key = id(d.requestId), cents = money(d.amount);
  const evidencePath = text(d.evidencePath, 300);
  if (!evidencePath.startsWith(`receipts/${a.uid}/${key}/`)) fail('Invalid receipt.');
  await verifyUpload(evidencePath, true);
  await db.runTransaction(async tx => {
    const target = ref('donations', key), previous = await tx.get(target);
    if (previous.exists) { if (previous.data().userId !== a.uid) fail('Identifier already in use.'); return; }
    tx.create(target, {userId: a.uid, userName: a.fullName, amount: cents / 100, amountCents: cents,
      source: 'manual', status: 'pending', evidencePath, message: String(d.message || '').slice(0, 1000), createdAt: stamp()});
    notification(tx, `receipt_${key}`, 'Receipt awaiting review', 'A donor submitted payment evidence.');
  }); return {ok: true};
});

async function settlePayment(paymentId, session = null, reviewer = null, bankReference = null) {
  await db.runTransaction(async tx => {
    const payment = ref('payments', paymentId), donation = ref('donations', paymentId);
    const target = session ? payment : donation, s = await tx.get(target);
    if (!s.exists) fail('Payment not found.'); const d = s.data();
    if (d.status === 'paid' || d.status === 'verified') return;
    if (d.status !== 'pending') fail('Payment is no longer pending.');
    if (session && (session.payment_status !== 'paid' || session.amount_total !== d.amountCents || session.currency !== 'myr' || session.metadata.paymentId !== paymentId || (d.sessionId && d.sessionId !== session.id))) fail('Payment verification failed.');
    if (d.projectId && !(await tx.get(ref('fundraising', d.projectId))).exists) fail('Project not found.');
    let referenceRecord;
    if (!session) {
      bankReference = text(bankReference, 100);
      referenceRecord = ref('bank_references', createHash('sha256').update(bankReference.replace(/\s/g, '').toLowerCase()).digest('hex'));
      if ((await tx.get(referenceRecord)).exists) fail('This bank transaction was already recorded.');
    }
    const grant = await prepareReward(tx, d.userId, `payment_${paymentId}`, Math.round(d.amountCents / 100)); grant();
    if (referenceRecord) tx.create(referenceRecord, {paymentId, bankReference, createdAt: stamp()});
    const common = {...d, status: 'verified', verifiedAt: stamp(), reviewedBy: reviewer, bankReference, ...(session ? {sessionId: session.id, paymentIntent: session.payment_intent} : {})};
    tx.update(target, {...common, status: session ? 'paid' : 'verified'});
    if (d.kind === 'shop') tx.set(ref('orders', paymentId), {...common, status: 'paid', total: d.amountCents / 100});
    else if (session) tx.set(donation, {...common, amount: d.amountCents / 100});
    tx.create(ref('ledger', paymentId), {kind: d.kind === 'shop' ? 'sale' : 'donation', amountCents: d.amountCents, userId: d.userId, createdAt: stamp()});
    tx.set(ref('finance', 'summary'), {balanceCents: F.increment(d.amountCents), [d.kind === 'shop' ? 'salesCents' : 'donationsCents']: F.increment(d.amountCents)}, {merge: true});
    if (d.projectId) tx.update(ref('fundraising', d.projectId), {raisedAmount: F.increment(d.amountCents / 100)});
    notification(tx, `paid_${paymentId}`, 'Payment verified', `RM ${(d.amountCents / 100).toFixed(2)} received.`, d.userId, 'personal');
  });
}

exports.reviewDonation = callable(async r => {
  const a = await actor(r, false, true), key = id(r.data.id);
  if (r.data.approve === true) await settlePayment(key, null, a.uid, r.data.reference);
  else await db.runTransaction(async tx => {
    const target = ref('donations', key), s = await tx.get(target);
    if (!s.exists || s.data().status !== 'pending') fail('Receipt already reviewed.');
    tx.update(target, {status: 'rejected', reviewedBy: a.uid, reviewNote: text(r.data.note), reviewedAt: stamp()});
  }); return {ok: true};
});

exports.createCheckout = callable(async r => {
  const a = await actor(r), d = r.data, key = `${a.uid}_${id(d.requestId)}`, target = ref('payments', key);
  const base = returnUrl.value(); if (!base.startsWith('https://')) fail('Payment return URL is not configured.');
  const stripe = new Stripe(stripeKey.value());
  const payment = await db.runTransaction(async tx => {
    const existing = await tx.get(target); if (existing.exists) return existing.data();
    let amountCents, items = [];
    if (d.kind === 'shop') {
      if (!Array.isArray(d.items) || !d.items.length || d.items.length > 30) fail('Invalid cart.');
      const seen = new Set();
      for (const item of d.items) {
        const itemId = id(item.itemId);
        if (seen.has(itemId) || !Number.isInteger(item.quantity) || item.quantity < 1 || item.quantity > 20) fail('Invalid quantity.'); seen.add(itemId);
        const s = await tx.get(ref('shop_items', itemId)), p = s.data();
        if (!p || p.active !== true) fail('An item is no longer available.');
        items.push({itemId, name: p.name, quantity: item.quantity, price: p.price, priceCents: money(p.price)});
      }
      const user = (await tx.get(ref('users', a.uid))).data();
      amountCents = Math.round(items.reduce((sum, i) => sum + i.priceCents * i.quantity, 0) * (1 - discountFor(user.points || 0)));
      if (amountCents > 10000000) fail('Cart total is too large.');
    } else if (d.kind === 'donation') amountCents = money(d.amount);
    else fail('Invalid payment kind.');
    if (d.projectId) {
      const project = (await tx.get(ref('fundraising', id(d.projectId)))).data();
      if (d.kind !== 'donation' || !project || !project.active || project.archived) fail('Project is unavailable.');
    }
    const data = {kind: d.kind, items, userId: a.uid, userName: a.fullName, amountCents, projectId: d.projectId || null, source: 'stripe', status: 'pending', createdAt: stamp()};
    tx.create(target, data); return data;
  });
  if (payment.status !== 'pending') fail('This checkout is already complete.');
  const session = await stripe.checkout.sessions.create({mode: 'payment', payment_method_types: ['card'],
    customer_email: a.email, client_reference_id: key, metadata: {paymentId: key},
    line_items: [{quantity: 1, price_data: {currency: 'myr', unit_amount: payment.amountCents, product_data: {name: payment.kind === 'shop' ? 'UTM Paws-itive order' : 'UTM Paws-itive donation'}}}],
    success_url: base, cancel_url: base}, {idempotencyKey: key});
  await target.update({sessionId: session.id});
  return {url: session.url, paymentId: key};
}, {secrets: [stripeKey]});

exports.stripeWebhook = onRequest({region, secrets: [stripeKey, webhookKey]}, async (req, res) => {
  const stripe = new Stripe(stripeKey.value()); let event;
  try { event = stripe.webhooks.constructEvent(req.rawBody, req.headers['stripe-signature'], webhookKey.value()); }
  catch (_) { res.status(400).send('Invalid signature'); return; }
  try {
    if (['checkout.session.completed', 'checkout.session.async_payment_succeeded'].includes(event.type)) {
      const session = event.data.object;
      if (session.payment_status === 'paid') await settlePayment(id(session.metadata.paymentId), session);
    }
    if (event.type === 'charge.refunded') {
      const charge = event.data.object;
      const payments = await db.collection('payments').where('paymentIntent', '==', charge.payment_intent).limit(1).get();
      if (!payments.empty) await db.runTransaction(async tx => {
        const target = payments.docs[0].ref, p = (await tx.get(target)).data();
        const delta = charge.amount_refunded - (p.refundedCents || 0); if (delta <= 0) return;
        const pts = Math.round((p.amountCents - charge.amount_refunded) / 100) - Math.round((p.amountCents - (p.refundedCents || 0)) / 100);
        const grant = await prepareReward(tx, p.userId, `refund_${event.id}`, pts); grant();
        const patch = {refundedCents: charge.amount_refunded, status: charge.amount_refunded >= p.amountCents ? 'refunded' : 'paid'};
        tx.update(target, patch);
        tx.update(ref(p.kind === 'shop' ? 'orders' : 'donations', target.id), {...patch, status: p.kind === 'shop' ? patch.status : patch.status === 'paid' ? 'verified' : 'refunded'});
        tx.create(ref('ledger', event.id), {kind: 'refund', amountCents: -delta, paymentId: target.id, createdAt: stamp()});
        tx.set(ref('finance', 'summary'), {balanceCents: F.increment(-delta), [p.kind === 'shop' ? 'salesCents' : 'donationsCents']: F.increment(-delta)}, {merge: true});
        if (p.projectId) tx.update(ref('fundraising', p.projectId), {raisedAmount: F.increment(-delta / 100)});
      });
      else fail('Payment has not been recorded yet; retry this refund event.');
    }
    res.sendStatus(200);
  } catch (e) { console.error(e); res.status(500).send('Retry processing'); }
});

exports.reviewFundRequest = callable(async r => {
  const a = await actor(r, false, true), d = r.data, target = ref('fund_requests', id(d.id));
  await db.runTransaction(async tx => {
    const [s, balance] = await tx.getAll(target, ref('finance', 'summary')); if (!s.exists) fail('Request not found.');
    const request = s.data(), cents = money(request.amount), totals = balance.data() || {};
    const next = text(d.status, 30);
    if (request.status === next) return;
    if (next === 'approved' && request.status === 'pending') {
      if ((totals.balanceCents || 0) - (totals.reservedCents || 0) < cents) fail('Insufficient available funds.');
      tx.set(ref('finance', 'summary'), {reservedCents: F.increment(cents)}, {merge: true});
    } else if (next === 'rejected' && ['pending', 'approved'].includes(request.status)) {
      if (request.status === 'approved') tx.set(ref('finance', 'summary'), {reservedCents: F.increment(-cents)}, {merge: true});
    } else if (next === 'disbursed' && request.status === 'approved') {
      const bankReference = text(d.reference, 100);
      if ((totals.balanceCents || 0) < cents) fail('Balance is insufficient after refunds.');
      tx.create(ref('ledger', `expense_${target.id}`), {kind: 'expense', amountCents: -cents, reference: bankReference, requestId: target.id, actorId: a.uid, createdAt: stamp()});
      tx.set(ref('finance', 'summary'), {reservedCents: F.increment(-cents), balanceCents: F.increment(-cents), expensesCents: F.increment(cents)}, {merge: true});
    } else fail('Invalid funding transition.');
    tx.update(target, {status: next, reviewedBy: a.uid, reviewNote: String(d.reference || d.note || ''), reviewedAt: stamp()});
    notification(tx, `fund_${target.id}_${next}`, 'Funding update', `Your request is ${next}.`, request.requestedBy, 'personal');
  }); return {ok: true};
});

exports.createFundRequest = callable(async r => {
  const a = await actor(r, true), d = r.data, reportId = id(d.reportId), requestId = id(d.requestId);
  const cents = money(d.amount), reason = text(d.reason);
  await db.runTransaction(async tx => {
    const target = ref('fund_requests', requestId);
    const [existing, s] = await tx.getAll(target, ref('reports', reportId));
    if (existing.exists) { if (existing.data().requestedBy !== a.uid) fail('Identifier already used.'); return; }
    if (!s.exists || s.data().archived) fail('Report is unavailable.');
    const report = s.data();
    if (a.role !== 'admin' && report.assignedVolunteerId !== a.uid) fail('Only the assigned volunteer may request funding.', 'permission-denied');
    tx.create(target, {catId: report.catId, catName: report.catName || report.locationName, reportId,
      requestedBy: a.uid, requestedByName: a.fullName, amount: cents / 100, reason, status: 'pending', createdAt: stamp()});
    notification(tx, `fund_request_${requestId}`, 'Funding requested', `${a.fullName} requested RM ${(cents / 100).toFixed(2)}.`);
  }); return {ok: true};
});

exports.sendNotification = onDocumentCreated({document: 'notifications/{id}', region, retry: true}, async event => {
  const n = event.data.data();
  let query = db.collection('users');
  if (n.targetUserId) query = query.where('__name__', '==', n.targetUserId);
  else query = query.where('role', 'in', n.audience === 'admins' ? ['admin'] : ['admin', 'volunteer']);
  const users = await query.get();
  const tokens = users.docs.filter(u => !u.data().isSuspended && (n.targetUserId || u.data().available !== false) && (u.data().role !== 'volunteer' || u.data().isApprovedVolunteer) && u.data().pushToken).map(u => u.data().pushToken);
  for (let i = 0; i < tokens.length; i += 500) await getMessaging().sendEachForMulticast({tokens: tokens.slice(i, i + 500), notification: {title: n.title, body: n.body}, data: {notificationId: event.params.id, reportId: n.reportId || ''}});
});

exports.escalateUrgentCases = onSchedule({schedule: 'every 15 minutes', region}, async () => {
  const cases = await db.collection('reports').where('urgency', '==', 'urgent').where('escalated', '==', false).where('status', 'in', ['reported', 'underReview']).where('responseDueAt', '<=', Timestamp.now()).limit(100).get();
  for (const report of cases.docs) await db.runTransaction(async tx => {
    const target = ref('notifications', `overdue_${report.id}`);
    if ((await tx.get(target)).exists) return;
    const fresh = (await tx.get(report.ref)).data();
    if (!fresh || fresh.archived || !['reported', 'underReview'].includes(fresh.status)) return;
    notification(tx, target.id, 'Urgent case needs a response', fresh.locationName, null, 'admins', report.id);
    tx.update(report.ref, {escalated: true});
  });
});

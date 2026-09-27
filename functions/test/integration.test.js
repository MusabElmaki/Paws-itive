const {test, before, beforeEach, after} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {initializeTestEnvironment, assertFails, assertSucceeds} = require('@firebase/rules-unit-testing');
const {doc, setDoc, updateDoc, getDoc, collection, query, where, getDocs} = require('firebase/firestore');
const enabled = !!process.env.FIRESTORE_EMULATOR_HOST && !!process.env.FIREBASE_STORAGE_EMULATOR_HOST;
let env, db, api;
const profile = (role = 'user', extra = {}) => ({fullName: 'Test user', email: 'test@example.com', role, status: 'active', isSuspended:false, isApprovedVolunteer:role !== 'user', points:0, ...extra});
const request = (uid, data) => ({auth:{uid, token:{email_verified:true, email:'test@example.com'}}, data});
before(async () => {
  if (!enabled) return;
  process.env.GCLOUD_PROJECT = 'demo-pawsitive';
  process.env.STRIPE_SECRET_KEY = 'sk_test_emulator';
  process.env.STRIPE_WEBHOOK_SECRET = 'whsec_emulator';
  env = await initializeTestEnvironment({projectId:'demo-pawsitive', firestore:{rules:fs.readFileSync(path.join(__dirname,'../../firestore.rules'),'utf8')}, storage:{rules:fs.readFileSync(path.join(__dirname,'../../storage.rules'),'utf8')}});
  api = require('../index'); db = require('firebase-admin/firestore').getFirestore();
});
beforeEach(async () => { if (enabled) await env.clearFirestore(); });
after(async () => { if (enabled) await env.cleanup(); });
function integration(name, fn) { test(name, {skip:!enabled}, fn); }
async function seed() {
  for (const [uid,p] of Object.entries({user:profile(), admin:profile('admin'), v1:profile('volunteer'), v2:profile('volunteer'), pending:profile('volunteer',{isApprovedVolunteer:false,status:'pending'}), suspended:profile('volunteer',{isSuspended:true,status:'suspended'})})) await db.doc(`users/${uid}`).set(p);
}
function client(uid) { return env.authenticatedContext(uid, {email_verified:true, email:'test@example.com'}).firestore(); }

integration('rules block role/points/suspension escalation and forged paid records', async () => {
  await seed(); const c = client('user');
  for (const patch of [{role:'admin'}, {points:9999}, {isSuspended:false}, {isApprovedVolunteer:true}]) {
    // Change isSuspended to true first so the attempted self-unsuspension is a real diff.
    if ('isSuspended' in patch) await db.doc('users/user').update({isSuspended:true});
    await assertFails(updateDoc(doc(c,'users/user'),patch));
  }
  await db.doc('users/user').update({isSuspended:false});
  await assertSucceeds(updateDoc(doc(c,'users/user'),{fullName:'New name'}));
  await assertFails(setDoc(doc(c,'orders/fake'),{userId:'user',status:'paid',total:20}));
  await assertFails(setDoc(doc(c,'cats/fake'),{name:'Forged cat'}));
  await assertFails(setDoc(doc(c,'leaderboard/user'),{points:9000}));
});
integration('users cannot create an administrator profile or impersonate email', async () => {
  const c = client('new');
  await assertFails(setDoc(doc(c,'users/new'), profile('admin')));
  await assertFails(setDoc(doc(c,'users/new'), profile('user',{email:'other@example.com'})));
  await assertSucceeds(setDoc(doc(c,'users/new'), profile()));
});
integration('notifications are scoped to recipients and approved staff', async () => {
  await seed();
  await db.doc('notifications/personal').set({targetUserId:'v1',audience:'personal'});
  await db.doc('notifications/staff').set({targetUserId:null,audience:'volunteers'});
  await assertFails(getDoc(doc(client('user'),'notifications/personal')));
  await assertSucceeds(getDoc(doc(client('v1'),'notifications/personal')));
  await assertFails(getDoc(doc(client('pending'),'notifications/staff')));
  await assertFails(getDoc(doc(client('suspended'),'notifications/staff')));
  await assertSucceeds(getDocs(query(collection(client('user'),'notifications'),where('targetUserId','==','user'))));
});
async function caseSeed() {
  await seed();
  await db.doc('cats/cat').set({name:'Oyen',photoUrls:['photo'],medicalNotes:['Keep this'],imageSignature:[1,2],currentStatus:'reported'});
  await db.doc('reports/report').set({catId:'cat',originalCatId:'cat',reporterId:'user',locationName:'Library',status:'reported',assignedVolunteerId:null});
}
integration('concurrent claims have one winner, preserve cat history and award once', async () => {
  await caseSeed();
  const results = await Promise.allSettled(['v1','v2'].map(uid => api.changeCase.run(request(uid,{reportId:'report',volunteerId:uid}))));
  assert.equal(results.filter(r=>r.status === 'fulfilled').length,1);
  const report = (await db.doc('reports/report').get()).data();
  const cat = (await db.doc('cats/cat').get()).data();
  assert.deepEqual(cat.medicalNotes,['Keep this']); assert.equal(cat.name,'Oyen'); assert.deepEqual(cat.photoUrls,['photo']);
  const winner = report.assignedVolunteerId;
  await api.changeCase.run(request(winner,{reportId:'report',volunteerId:winner}));
  assert.equal((await db.doc(`users/${winner}`).get()).data().points,10);
  await api.changeCase.run(request(winner,{reportId:'report',status:'resolved'}));
  await api.changeCase.run(request(winner,{reportId:'report',status:'resolved'}));
  assert.equal((await db.doc(`users/${winner}`).get()).data().points,40);
  await assert.rejects(api.changeCase.run(request(winner,{reportId:'report',status:'beingAssisted'})));
});
integration('pending and suspended volunteers cannot call privileged commands', async () => {
  await caseSeed();
  for (const uid of ['pending','suspended','user']) await assert.rejects(api.changeCase.run(request(uid,{reportId:'report',volunteerId:uid})));
  await assert.rejects(api.manageUser.run(request('user',{uid:'v1',role:'admin'})));
});
integration('duplicate linking and undo preserve original records', async () => {
  await caseSeed();
  await db.doc('cats/other').set({name:'Other',medicalNotes:['Original history']});
  await db.doc('reports/report').update({candidateCatId:'other',duplicateStatus:'pending',description:'Sighting',photoUrl:'photo'});
  await api.reviewDuplicate.run(request('v1',{reportId:'report',decision:'link'}));
  assert.equal((await db.doc('reports/report').get()).data().catId,'other');
  assert.deepEqual((await db.doc('cats/other').get()).data().medicalNotes,['Original history']);
  await api.reviewDuplicate.run(request('v1',{reportId:'report',decision:'undo'}));
  assert.equal((await db.doc('reports/report').get()).data().catId,'cat');
  assert.deepEqual((await db.doc('cats/cat').get()).data().medicalNotes,['Keep this']);
});
integration('receipt approval is atomic and idempotent; no rewards before review', async () => {
  await seed();
  await require('firebase-admin/storage').getStorage().bucket().file('receipts/user/receipt/photo.jpg').save(Buffer.from([255,216,255,217]), {contentType:'image/jpeg'});
  await api.submitManualDonation.run(request('user',{requestId:'receipt',amount:20,evidencePath:'receipts/user/receipt/photo.jpg'}));
  assert.equal((await db.doc('users/user').get()).data().points,0);
  await Promise.all([1,2].map(()=>api.reviewDonation.run(request('admin',{id:'receipt',approve:true,reference:'BANK-RECEIPT'}))));
  assert.equal((await db.doc('users/user').get()).data().points,20);
  assert.equal((await db.doc('finance/summary').get()).data().balanceCents,2000);
  assert.equal((await db.collection('ledger').get()).size,1);
});
integration('receipt storage is owner-private and immutable', async () => {
  await seed(); const {ref,uploadBytes,getBytes} = require('firebase/storage');
  const owner = env.authenticatedContext('user',{email_verified:true}).storage();
  const other = env.authenticatedContext('v1',{email_verified:true}).storage();
  const path = 'receipts/user/storage-test/receipt.jpg';
  await assertSucceeds(uploadBytes(ref(owner,path),new Uint8Array([1,2,3]),{contentType:'image/jpeg'}));
  await assertSucceeds(getBytes(ref(owner,path)));
  await assertFails(getBytes(ref(other,path)));
  await assertFails(uploadBytes(ref(owner,path),new Uint8Array([4]),{contentType:'image/jpeg'}));
  await assertFails(uploadBytes(ref(other,'reports/user/forged/photo.jpg'),new Uint8Array([1]),{contentType:'image/jpeg'}));
});
integration('report retry creates one sighting and never overwrites the suggested cat', async () => {
  await seed();
  await db.doc('cats/existing').set({name:'Oyen',medicalNotes:['Medication'],photoUrls:['old-photo']});
  const photoPath='reports/user/sighting/photo.jpg';
  await require('firebase-admin/storage').getStorage().bucket().file(photoPath).save(Buffer.from([255,216,255,217]),{contentType:'image/jpeg'});
  const data={requestId:'sighting',photoPath,locationName:'Library',reportedCondition:'Injured',imageSignature:Array(128).fill(.1),candidateCatId:'existing',latitude:null,longitude:null};
  await api.submitReport.run(request('user',data)); await api.submitReport.run(request('user',data));
  assert.equal((await db.collection('reports').get()).size,1);
  assert.equal((await db.doc('reports/sighting').get()).data().latitude,null);
  assert.equal((await db.doc('reports/sighting').get()).data().catId,'sighting');
  assert.deepEqual((await db.doc('cats/existing').get()).data().medicalNotes,['Medication']);
  assert.equal((await db.doc('users/user').get()).data().points,0);
});
integration('fund approval reserves balance and disbursement records one expense', async () => {
  await seed(); await db.doc('finance/summary').set({balanceCents:3000,reservedCents:0});
  for (const id of ['a','b']) await db.doc(`fund_requests/${id}`).set({amount:20,status:'pending',requestedBy:'v1'});
  const results = await Promise.allSettled(['a','b'].map(id=>api.reviewFundRequest.run(request('admin',{id,status:'approved'}))));
  assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
  const winner=(await db.doc('fund_requests/a').get()).data().status==='approved'?'a':'b';
  for (let i=0;i<2;i++) await api.reviewFundRequest.run(request('admin',{id:winner,status:'disbursed',reference:'BANK-123'}));
  const balance=(await db.doc('finance/summary').get()).data();
  assert.equal(balance.balanceCents,1000); assert.equal(balance.reservedCents,0);
  assert.equal((await db.collection('ledger').get()).size,1);
});
async function webhook(event, signatureValid = true) {
  const Stripe=require('stripe'), stripe=new Stripe('sk_test_emulator'), rawBody=Buffer.from(JSON.stringify(event));
  const signature=stripe.webhooks.generateTestHeaderString({payload:rawBody.toString(),secret:signatureValid?'whsec_emulator':'wrong'});
  let status=200;
  const response={status(n){status=n;return this;},send(){return this;},sendStatus(n){status=n;return this;}};
  await api.stripeWebhook({rawBody,headers:{'stripe-signature':signature}},response);
  return status;
}
integration('signed Stripe event verifies amount and retries do not double-count shop revenue', async () => {
  await seed();
  await db.doc('payments/payment').set({kind:'shop',amountCents:2000,userId:'user',userName:'Test',status:'pending',source:'stripe',items:[]});
  const session={id:'cs_test',metadata:{paymentId:'payment'},payment_status:'paid',amount_total:2000,currency:'myr',payment_intent:'pi_test'};
  const event={id:'evt_test',type:'checkout.session.completed',data:{object:session}};
  assert.equal(await webhook(event,false),400);
  assert.equal(await webhook({...event,data:{object:{...session,amount_total:100}}}),500);
  assert.equal(await webhook(event),200); assert.equal(await webhook(event),200);
  assert.equal((await db.doc('finance/summary').get()).data().balanceCents,2000);
  assert.equal((await db.collection('donations').get()).size,0);
  assert.equal((await db.doc('orders/payment').get()).data().status,'paid');
  const refund={id:'evt_refund',type:'charge.refunded',data:{object:{payment_intent:'pi_test',amount_refunded:500}}};
  assert.equal(await webhook(refund),200); assert.equal(await webhook(refund),200);
  assert.equal((await db.doc('finance/summary').get()).data().balanceCents,1500);
  assert.equal((await db.doc('users/user').get()).data().points,15);
});

// Run only after an export/backup. Defaults to a read-only audit.
// Never infer trusted roles from the old user-writable role field.
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
initializeApp();
const db = getFirestore();
const apply = process.argv.includes('--apply');
const trustedAdmins = new Set((process.env.TRUSTED_ADMIN_UIDS || '').split(',').filter(Boolean));
const trustedVolunteers = new Set((process.env.TRUSTED_VOLUNTEER_UIDS || '').split(',').filter(Boolean));
async function main() {
  if (apply && !trustedAdmins.size) throw new Error('Specify independently verified TRUSTED_ADMIN_UIDS before applying.');
  let counts = {};
  for (const collection of ['users','leaderboard','donations','orders','cats','fundraising','reports']) {
    const documents = await db.collection(collection).get(); let changed = 0;
    for (const doc of documents.docs) {
      const d = doc.data(); let patch = null;
      if (collection === 'users' && !d.securityMigrationV1) {
        const role = trustedAdmins.has(doc.id) ? 'admin' : trustedVolunteers.has(doc.id) ? 'volunteer' : 'user';
        patch = {role, isApprovedVolunteer: role !== 'user', isSuspended: d.isSuspended === true,
          status: d.isSuspended ? 'suspended' : 'active', points: 0, securityMigrationV1: true,
          legacyRole: d.role || 'user', legacyPoints: d.points || 0};
      }
      if (collection === 'leaderboard' && !d.securityMigrationV1) patch = {points:0, weeklyPoints:0, monthlyPoints:0, securityMigrationV1:true, legacyPoints:d.points || 0};
      if (['donations','orders'].includes(collection) && !d.verifiedAt && !d.securityMigrationV1) patch = {legacyStatus:d.status || null, status:'legacy_unverified', securityMigrationV1:true};
      // These exact coordinates were inserted regardless of the written location.
      if (['cats','reports'].includes(collection) && d.latitude === 1.5603 && d.longitude === 103.6378) patch = {latitude:null,longitude:null,locationNeedsReview:true};
      if (collection === 'fundraising' && !d.securityMigrationV1) patch = {legacyRaisedAmount:d.raisedAmount || 0,raisedAmount:0,securityMigrationV1:true};
      if (collection === 'reports' && !d.originalCatId && d.catId) patch = {...patch,originalCatId:d.catId,duplicateStatus:'none',escalated:false,urgency:'normal'};
      if (patch) {
        changed++;
        if (apply) {
          const batch = db.batch();
          batch.update(doc.ref,patch);
          const previous = Object.fromEntries(Object.keys(patch).filter(key => key in d).map(key => [key,d[key]]));
          batch.set(db.collection('audit_log').doc(`migration_${collection}_${doc.id}`),{action:'security_migration_v1',collection,recordId:doc.id,previous,createdAt:FieldValue.serverTimestamp()});
          await batch.commit();
        }
      }
    }
    counts[collection] = changed;
  }
  console.log(JSON.stringify({mode:apply?'applied':'dry-run',recordsToChange:counts},null,2));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});

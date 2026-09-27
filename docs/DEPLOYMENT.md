# Run and deploy the corrected application

The source is updated locally. No production database, Firebase rules, Functions,
bank configuration, or Stripe account was changed by this code update.

## Prerequisites

- Flutter matching `pubspec.yaml` (Dart 3.11 or newer).
- Node 22 for Cloud Functions, Java 21 for Firebase emulators, Firebase CLI.
- Firebase Authentication email/password enabled, Firestore, Storage and billing
  enabled for Functions/Storage/Scheduler. The backend runs in `asia-southeast1`.
- Stripe secret API key and webhook signing secret. Never put these in Flutter.

## Install and verify

From the project root:

```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
```

Install backend packages **from the functions directory**:

```powershell
Set-Location functions
npm ci
Set-Location ..
$env:DEBUG = ''
firebase.cmd emulators:exec --project demo-pawsitive --only "firestore,storage" "npm --prefix functions test"
```

The test command uses a demo project and never touches production. Running `npm
test` without emulator variables runs pure policy tests and skips integration
tests. Both Firestore and Storage emulators are required for the full suite.

## Upgrade an existing database

1. Export/back up Firestore and Storage. Schedule a maintenance window and prevent
   writes from old app versions before migrating; old versions are incompatible
   with the new write restrictions.
2. Independently confirm administrator and approved-volunteer UIDs. The old
   `role` field was user-writable and cannot establish trust.
3. Run `functions/scripts/migrate-legacy.js` using Application Default Credentials
   for the intended Firebase project. Its default is a **read-only audit**:

   ```powershell
   $env:GOOGLE_CLOUD_PROJECT = 'utm-paws-itive'
   node functions/scripts/migrate-legacy.js
   ```

4. Review that audit and your export. To apply the migration deliberately:

   ```powershell
   $env:TRUSTED_ADMIN_UIDS = 'independently-verified-admin-uid'
   $env:TRUSTED_VOLUNTEER_UIDS = 'approved-volunteer-uid'
   node functions/scripts/migrate-legacy.js --apply
   ```

   This resets untrusted privileges and rewards, preserves previous values and
   audit records, marks old payments `legacy_unverified`, resets unverified
   fundraising totals, and clears coordinates equal to the old hardcoded pin.
   It does not charge, refund, or transfer money. Review older bank and Stripe
   transactions before incorporating them into a separately audited opening
   balance. Existing totals are intentionally **not** assumed to be real income.
   Previously erased cat history must be recovered from backups; code cannot
   reconstruct missing historical information.

5. On a new database, register and verify the first administrator's email, then
   set that specific user's role to `admin` using the Firebase Console or trusted
   Admin SDK. Set `status: active`, `isSuspended: false`. Never add a client-side
   administrator registration option.

## Configure and deploy the backend

```powershell
firebase.cmd functions:secrets:set STRIPE_SECRET_KEY
firebase.cmd functions:secrets:set STRIPE_WEBHOOK_SECRET
firebase.cmd deploy --only "firestore,storage,functions,hosting"
```

At the deployment prompt, set `PAYMENT_RETURN_URL` to the HTTPS hosted page,
for example `https://utm-paws-itive.web.app/payment-complete.html`. Use a URL
belonging to your deployment. The return page never asserts that a payment was
successful. Only a signed Stripe event can settle a card payment.

Register the deployed `stripeWebhook` HTTPS URL in Stripe, with these events:

- `checkout.session.completed`
- `checkout.session.async_payment_succeeded`
- `charge.refunded`

Use keys and webhook secrets from the same Stripe mode/account. Test with Stripe
test keys before switching to live mode. Refunds are initiated in the Stripe
Dashboard and reconciled by the signed refund webhook. Delayed and repeated
events are supported; configure monitoring/replay for failed webhook deliveries.

The first Storage rules deployment using Firestore lookups may ask Firebase to
enable cross-service permissions. Allow that integration for the selected project.
For Flutter web, configure the Storage bucket's CORS for the actual app origin
before using SDK byte downloads. Restrict origins to your deployed app sites.

## Configure manual bank transfers

Manual transfers stay disabled until all real bank details are supplied:

```powershell
flutter run --dart-define=BANK_NAME="Your bank" --dart-define=BANK_ACCOUNT_HOLDER="Your society" --dart-define=BANK_ACCOUNT_NUMBER="Your real account"
```

Use the same defines for a build. Fake DuitNow payloads and the old Stripe QR
fallback are removed. A receipt is a pending claim, not proof of settlement.
An administrator must compare it with the bank record and enter a unique bank
transaction reference. Approval atomically updates the ledger, rewards and
verified balance. Duplicate bank references are rejected.

Funding approval reserves verified funds. After making the actual bank transfer,
the administrator records the disbursement reference. Approving a request does
not itself transfer money. Cancelling approval releases its reservation.

## Notifications and mobile platforms

The in-app inbox works from Firestore. Device push additionally needs working
Firebase Messaging configuration (including APNs credentials and capabilities
for iOS and notification permission on Android). Tokens refresh automatically;
volunteers can toggle availability. Urgent unclaimed reports are escalated to
administrators by the scheduled backend job. First test notification receipt on
physical devices; emulator tests do not contact FCM or Stripe.

GPS is optional. Users can select a pin manually or submit a written location
with unknown coordinates. iOS permission descriptions and Android location and
notification permissions are included. iOS builds require macOS/Xcode and have
not been built on this Windows workspace.

## Source layout

- `lib/app`: authentication gate and role navigation.
- `lib/features/*_pages.dart`: feature screens; `feature_pages.dart` is their
  shared library entry point. Payment/review workflows are in `workflow_pages.dart`.
- `lib/core/workflows.dart`: injectable backend command client and local drafts.
- `lib/core/services.dart`: injectable database reads and bounded subscriptions.
- `functions/index.js`: validated server commands, transactions, signed payment
  webhooks, notifications and escalation.
- `functions/policy.js`: pure money, transition and coordinate validation.
- `firestore.rules`, `storage.rules`, `firestore.indexes.json`: deployed access
  boundaries and query indexes.
- `archive/legacy_flutter`: disconnected prototype retained for reference.
- `src/` and `Figma Make Designs/`: React design references, not the shipped app.

Main feeds show the latest 100 entries. Reports, active cases and cat profiles
provide cursor-paged history. Images and receipts are private Storage objects,
not base64 fields in new Firestore documents. Similarity is advisory, never an
identity probability; every proposed link needs an approved volunteer/admin.

Before an app-store release, configure release signing, verify actual clinic
contacts, complete a live-device acceptance run, and deploy all backend components
together. No third-party service credentials are bundled in the source archive.

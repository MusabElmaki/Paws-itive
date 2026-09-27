# UTM Paws-itive

Flutter and Firebase application for reporting and coordinating campus cat care.

The updated app uses verified email accounts, approved volunteer roles, transactional
case assignment, preserved care timelines, GPS/map sightings, saved report drafts,
reviewable duplicate suggestions, private payment evidence and server-verified payments.

Read [deployment and upgrade instructions](docs/DEPLOYMENT.md) before running against
an existing project. Deploy the new Cloud Functions, rules and indexes together.
Stripe and bank configuration are supplied separately; no live service was deployed
as part of this source update.

```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter run
```

Backend tests and data migration guidance are in `docs/DEPLOYMENT.md`.

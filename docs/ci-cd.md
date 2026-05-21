# CI/CD

This repo uses GitHub Actions for Flutter validation and Firebase deployment.

## Workflows

- `CI` runs on pull requests, pushes to `main`, and manual dispatch. It checks formatting, runs `flutter analyze`, runs tests, builds Flutter Web, builds an Android debug APK, and checks Firebase Functions syntax.
- `Firebase Deploy` runs on pushes to `main` and manual dispatch. It repeats the Flutter checks, builds Web, checks Functions, then deploys Hosting, Firestore rules, and Functions to Firebase project `wasteless-app-2034e`.

## Required Secrets

Add these in GitHub under `Settings -> Secrets and variables -> Actions`.

- `FIREBASE_SERVICE_ACCOUNT`: full JSON for a Google Cloud service account that can deploy Firebase Hosting, Firestore rules, and Cloud Functions.
- `ENV_FILE`: optional contents for the app `.env` file. If this is not set, CI creates an empty `.env` so Flutter asset bundling still succeeds.

The Gemini Cloud Function also expects the Firebase Functions secret `GEMINI_API_KEY` to already exist in Firebase:

```sh
firebase functions:secrets:set GEMINI_API_KEY --project wasteless-app-2034e
```

## Firebase Deploy Target

The deployment workflow uses `firebase.json` and deploys:

```sh
firebase deploy --project wasteless-app-2034e --only hosting,firestore:rules,functions
```

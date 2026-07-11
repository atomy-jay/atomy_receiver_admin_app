# Atomy Receiver Admin App

A Flutter Android app for event staff to scan member QR codes, rent interpreter receivers, process returns and monitor live status.

## Features

- Member QR scanning
- Member number lookup
- Receiver rental
- Duplicate rental protection from the backend
- Receiver lookup and return
- Normal / damaged / lost / maintenance status
- Live dashboard refreshed every 10 seconds
- Navy, white and Atomy Blue interface

## Architecture

Android App → Netlify Functions → Supabase

The app does not contain the Supabase service role key. Your Netlify backend must be deployed before the app can process real data.

## Build APK

```bash
flutter pub get
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

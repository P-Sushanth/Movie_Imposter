# Movie Imposter — Build & Distribution Guide

This document explains how to run, test, and package **Movie Imposter** into an installable Android `.apk` file for sharing with friends or uploading to GitHub Releases.

---

## 1. Running the App Locally (Development)

### Prerequisites
- Node.js (v18+ recommended)
- Android or iOS phone with the free **Expo Go** app installed from the Google Play Store / Apple App Store.

### Steps
1. Install dependencies:
   ```bash
   npm install
   ```
2. Start the development server:
   ```bash
   npm start
   ```
3. A QR code will display in your terminal:
   - **On Android:** Open the **Expo Go** app and tap **Scan QR Code**.
   - **On iPhone:** Open the default **Camera** app, point it at the QR code, and tap the prompt to open in Expo Go.
4. The game will immediately load and run on your physical device with live reload enabled.

---

## 2. Running Verification & Unit Tests

Verify type safety and game engine acceptance criteria:

```bash
# Run TypeScript compilation check
npm run typecheck

# Run Jest unit tests (validation, filtering, clue generator, role assignment)
npm test
```

---

## 3. Building an Installable Android APK (.apk)

To create a standalone `.apk` file that anyone can download and install on any Android phone (without needing Expo Go or Android Studio):

### Step 1: Install EAS CLI
```bash
npm install -g eas-cli
```

### Step 2: Log in to Expo (Free)
Create a free account at [expo.dev](https://expo.dev) if you don't already have one, then run:
```bash
eas login
```

### Step 3: Configure EAS Build
Run:
```bash
eas build:configure
```
Ensure your `eas.json` includes an APK build profile:
```json
{
  "cli": {
    "version": ">= 12.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "android": {
        "buildType": "apk"
      }
    },
    "production": {}
  }
}
```

### Step 4: Trigger the Cloud APK Build
```bash
eas build -p android --profile preview
```
Expo's build servers will compile the app and provide a direct URL to download the finished `.apk` file.

---

## 4. Distributing via GitHub Releases

1. Download the `.apk` file from the EAS build completion page.
2. Go to your GitHub repository: `https://github.com/your-username/Imposter_Who/releases/new`.
3. Create a tag (e.g. `v1.0.0`), write a release summary, and attach `imposter-who.apk` as a binary asset.
4. Anyone visiting your GitHub repository can click the APK link, download it onto their Android phone, and play completely offline!

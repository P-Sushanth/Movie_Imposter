# Movie Imposter — Flutter Edition

This is the complete Flutter rewrite of **Movie Imposter**, an offline party game for Indian and international cinema lovers.

---

## 1. Prerequisites & Installation

To run and build this Flutter project locally, you need:
1. **Flutter SDK**
2. **Android Studio** (for the Android SDK and command-line tools)

### Quickest Install via Windows Package Manager (`winget`)

Open **PowerShell** as Administrator and run:

```powershell
# 1. Install Flutter SDK
winget install Flutter.Flutter

# 2. Install Android Studio
winget install Google.AndroidStudio
```

### Manual Install Alternative

- **Flutter SDK**: Download from [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows/mobile) and extract to `C:\src\flutter`. Add `C:\src\flutter\bin` to your system `PATH`.
- **Android Studio**: Download from [developer.android.com/studio](https://developer.android.com/studio) and follow the installer.

---

## 2. One-Time Android Setup

1. Open **Android Studio** → **More Actions** → **SDK Manager**:
   - Under **SDK Platforms**, ensure **Android 14 (API 34)** or higher is checked.
   - Under **SDK Tools**, check **Android SDK Command-line Tools (latest)** and click **Apply**.
2. Accept Android licenses in your terminal:
   ```powershell
   flutter doctor --android-licenses
   ```
   *(Press `y` to accept each license)*.
3. Verify your setup:
   ```powershell
   flutter doctor
   ```

---

## 3. Running the App Locally

Navigate into the `flutter_app` directory:

```powershell
cd flutter_app

# Fetch dependencies
flutter pub get

# Run unit tests (validation, clue generator, role assignment)
flutter test

# Run the app on your connected phone or emulator
flutter run
```

---

## 4. Building the Installable Standalone APK (.apk)

To build a standalone APK that can be uploaded to GitHub Releases:

```powershell
flutter build apk --release
```

Once the build finishes, your APK file will be located at:
```text
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

---

## 5. Free Distribution via GitHub Releases

1. Rename `app-release.apk` to `movie-imposter.apk`.
2. Go to your GitHub repository → **Releases** → **Draft a new release**.
3. Create a tag (e.g. `v1.0.0`) and title.
4. Drag and drop `movie-imposter.apk` into the release binaries area.
5. Click **Publish release**.

Anyone visiting your repository release page can download and install the app on their Android phone for **free**!

# Keystore Setup Instructions

## Problem
Your app bundle is signed with the wrong key. You need to use the keystore with SHA1 fingerprint:
**SHA1: 03:F9:44:6A:9F:3F:3B:CF:83:01:E7:D3:B3:C0:39:CE:A2:72:E6:0A**

## Solution Steps

### Option 1: Find Your Existing Keystore (Recommended)

1. **Run the find_keystore.ps1 script** (in project root):
   ```powershell
   .\find_keystore.ps1
   ```
   
   This will search for keystore files and verify their SHA1 fingerprints.

2. **If found**, copy the matching keystore file to:
   ```
   android/app/upload-keystore.jks
   ```

3. **Update key.properties** if needed (currently set to):
   ```properties
   storePassword=123456
   keyPassword=123456
   keyAlias=upload
   storeFile=../app/upload-keystore.jks
   ```

### Option 2: Manual Keystore Search

1. **Search manually** in these common locations:
   - Documents folder
   - Desktop
   - Downloads
   - Previous project folders
   - Backup drives/USB

2. **Verify SHA1** of any keystore file you find:
   ```powershell
   keytool -list -v -keystore "path\to\your\keystore.jks" -alias "upload" -storepass "your_password"
   ```
   
   Look for the SHA1 line and match it with: `03:F9:44:6A:9F:3F:3B:CF:83:01:E7:D3:B3:C0:39:CE:A2:72:E6:0A`

### Option 3: Download from Google Play Console (If Using App Signing)

If you're using Google Play App Signing:

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to **Setup > App Signing**
4. Download the upload certificate/key if available
5. Place it in `android/app/upload-keystore.jks`

### Option 4: Request Key Reset (Last Resort)

⚠️ **Warning**: This will create a NEW app with different package signature. Use only if you cannot recover the original key.

1. Contact Google Play Support
2. Request key reset (this may require creating a new app listing)

## Verify Setup

After placing the keystore file, verify the configuration:

```powershell
# Check if file exists
Test-Path android\app\upload-keystore.jks

# Verify SHA1 matches
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload -storepass 123456
```

The SHA1 should match: **03:F9:44:6A:9F:3F:3B:CF:83:01:E7:D3:B3:C0:39:CE:A2:72:E6:0A**

## Build the App Bundle

Once the keystore is in place:

```powershell
flutter build appbundle --release
```

The app bundle will be signed with the correct key and can be uploaded to Google Play.


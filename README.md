# workout_log


## Application for saving workout logs.

In logs, you can add date, exercise name, body part which you train, how many sets and repeats in each one did you do. 

<br>

 You can find it on Play Store:
 <br>
https://play.google.com/store/apps/details?id=com.lukk.workoutlog


---

Clean build files:
```
flutter clean
```

Get dependencies:
```
flutter pub get
```

Generate classes:
```
dart run build_runner build
```

Generate with deleting of conflicted ones:
```
dart run build_runner build --delete-conflicting-outputs
```

Find emulator id:
```
flutter devices
```

Run on a device:
```
flutter run -d <deviceId>
```
where `deviceId` is id from previous command eg. `emulator-5554`

Run in verbose mode:
```
flutter run -v -d <deviceId>
```

Run in release mode:
```
flutter run --release -d <deviceId>
```

---

### Deployment

1. Change app version 

2. [pubspec.yaml](./pubspec.yaml)
   ```
   version: X.Y.Z+A
   ```
   
3. Make sure [android/key.properties](./android/key.properties) `android/key.properties` are present and have correct passes:
   ```
   storePassword=XXX  
   keyPassword=XXX  
   keyAlias=key  
   storeFile=workout_log-keystore.jks
   ```
   
4. Run in the terminal (without an app folder) :
 
   ```
   flutter build appbundle
   ```
   
   `appbundle` will be generated in [release](./build/app/outputs/bundle/release/) folder:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
   rename to 
   ```
   workout_log-X.Y.Z.aab
   ```
   `X.Y.Z` - version number

---

### Publish

1. Go to
   [https://play.google.com/apps/publish](https://play.google.com/apps/publish)
   
2. Create a release (or create a new application if first published) and "Let Google manage and protect your app signing key"

   - upload bundle
   - enter the release name (same as in pubspec.yaml)
   - edit Store listening (icon, screenshots, feature graphic), content rating, app content and pricing& distribution PAGES

3. Start with "Internal testing" then rollout to alpha

---
### Signing app for the first time

Create keystore:

```
keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem
```

SAVE IT!

Every next version must be signed with the SAME keystore or Google won't publish it

Create a file name `<app dir>/android/key.properties` names must be same as generated before


Highlight

```
storePassword=< password from previous step >  
keyPassword=< password from previous step >  
keyAlias=upload-keystore  
storeFile=workout_log-keystore.jks  
```

where `workout_log-keystore.jks` needs to be [android root](./android) folder.  

This will link `key.properties` created before with Gradle.

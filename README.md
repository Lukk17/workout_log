# workout_log
[![Codemagic build status](https://api.codemagic.io/apps/5d0d2a8999fdb7001415b9b2/5d0d2a8999fdb7001415b9b1/status_badge.svg)](https://codemagic.io/apps/5d0d2a8999fdb7001415b9b2/5d0d2a8999fdb7001415b9b1/latest_build)


## Application for saving workout logs.

In logs you can add date, exercise name, body part which you train, how many sets and repeats in each one did you do. 

<br>

 You can find it on Play Store:
 <br>
https://play.google.com/store/apps/details?id=com.lukk.workoutlog


---

To generate classes:
```
flutter pub run build_runner build
```
---

### Deployment

1. Change app version 
 in `pubspec.yaml` 

 and `android/local.properties`:

```
sdk.dir=D:\\Development\\SDK\\Android\\sdk
flutter.sdk=D:\\Development\\SDK\\flutter
flutter.buildMode=release
flutter.versionName=1.2.2
flutter.versionCode=1
```


2. Make sure `android/key.properties` are present and have correct passes:
```
storePassword=XXX  
keyPassword=XXX  
keyAlias=key  
storeFile=workout_log-keystore.jks
```

4. Run in terminal (without app folder) :

```
flutter build appbundle
```

`appbundle` bedzie wygenerowany w folderze projektu:

```
build/app/outputs/bundle/release/app.aab
```

---

### Publish

1. Go to

[https://play.google.com/apps/publish](https://play.google.com/apps/publish)

2. Create new application with title, description etc

3. Create release (and "Let Google manage and protect your app signing key"):

- upload bundle
- enter release name (same as in pubspec.yaml)
- edit Store listining (icon, screenshots, feature graphic) , content rating, app content and pricing& distribution PAGES

4. Start with "Internal testing" then rollout to aplha

---
### Signing app for first time

create keystore:

```
keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem
```

SAVE IT!

later version must be signed with SAME keystore or google won't publish it

Create a file name `<app dir>/android/key.properties` names must be same as generated before


Highlight

```
storePassword=< password from previous step >  
keyPassword=< password from previous step >  
keyAlias=upload-keystore  
storeFile=< location of the key store file, such as /Home/< user name >/upload-keystore.jks >  
```

editing the`<app dir>/android/app/build.gradle`

this will link `key.properties` created before with gradle

```
def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   android {
```


```
signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile file(keystoreProperties['storeFile'])
           storePassword keystoreProperties['storePassword']
       }
   }
   buildTypes {
       release {
           signingConfig signingConfigs.release
       }
   }
```

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

Generate classes (freezed + json_serializable):
```
dart run build_runner build
```

If a regen fails because stale generated files conflict, wipe them first:
```
dart run build_runner clean
```
(The old `--delete-conflicting-outputs` flag was removed in `build_runner` 2.15+.)

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

Release builds ship to the Google Play Store via a manual GitHub
Actions workflow.

See [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) for the full
procedure: how to trigger a release, the five GitHub secrets you need
to configure (keystore + Google Play API service account), what the
workflow actually does step-by-step, common failure modes and their
fixes, and the manual `flutter build appbundle` path for when CI is
unavailable. The first-time keystore-signing setup is in there too.

# Pomodoro App (CS310 – Group 26)

Flutter study timer: Pomodoro timer, task list, study history/statistics, settings,
background notifications and email/password accounts (Firebase Auth + Cloud Firestore).

Screens follow the Step 2.1 wireframes: S1 Splash, S2 Log in, S3 Sign up, S4 Reset password,
S5/S6 Timer (focus/break), S7 Choose a task, S8 notification, S9 Tasks, S10 Add/edit task,
S11 Stats and history, S12 Settings.

## Setup

This repo contains `lib/`, `assets/`, `test/` and `pubspec.yaml`. Generate the platform
folders once and configure Firebase:

```bash
flutter create . --project-name pomodoro_app --org com.example --platforms android,ios
dart pub global activate flutterfire_cli
flutterfire configure        # overwrites lib/firebase_options.dart
flutter pub get
flutter run
```

In the Firebase console enable **Authentication → Email/Password** and create a **Cloud
Firestore** database. Deploy `firestore.rules` (each user can only read/write `users/{uid}/…`).

### Android (`android/app/src/main/AndroidManifest.xml`)

Inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32"/>
```

Inside `<application>` (needed by `flutter_local_notifications` for scheduled notifications):

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
  </intent-filter>
</receiver>
```

Also set `minSdk 23`+ and enable core library desugaring if the build asks for it
(see the `flutter_local_notifications` README).

## How it works

- **Timer** (`providers/timer_controller.dart`): remaining time is computed from an absolute
  end time, so it stays right if the OS pauses the app. When the app goes to the background a
  system notification is scheduled for the end of the phase; returning to the app cancels it.
  If a phase ended while away, the next phase is ready but paused (S8 → S6).
- Focus → short break, every N-th focus session → long break, then the cycle restarts.
- Finished focus sessions are saved to `users/{uid}/sessions` with the selected task.
  Stats (today, this week, per-day chart, history) and per-task time are computed from them.
- Data layout: `users/{uid}` (profile + `settings`), `users/{uid}/tasks`, `users/{uid}/sessions`.

## Known limitations

- Timer state is not restored if the app process is killed (the notification still fires).
- Volume applies to the in-app bell sound; the system notification sound follows the phone.
- Not compiled or run yet in the environment it was written in – run `flutter analyze` and
  `flutter test` first.

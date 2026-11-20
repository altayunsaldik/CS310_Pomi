# CS310_TermProject

# Pomi (Pomodoro App)

CS310 Mobile Application Development Term Project (Group 26)

## About

Pomodoro App is a study helper built with Flutter. It is based on the Pomodoro technique: study for 25 minutes, take a 5-minute break, and take a longer break after every four sessions. Users can connect each study session to a task and look back at their study history to follow their own progress.

Planned features:

- Pomodoro timer that switches between study time, short breaks and long breaks
- Adjustable session lengths, volume and vibration settings
- Task list where tasks can be linked to study sessions
- Study history with daily and weekly study time
- Notifications when a session or break ends
- User accounts with email and password

Built with Flutter, Firebase Authentication and Cloud Firestore.

## Group Members

| Name | Student ID |
| --- | --- |
| Ahmet Kağan İlerisoy (Step 1 Coordinator) | 35901 |
| Altay Ünsaldık | 34079 |
| Deniz Temel | 35683 |

## Run

1. Create a Firebase project, enable **Email/Password** auth and **Cloud Firestore**.
2. `dart pub global activate flutterfire_cli && flutterfire configure` (sets up `google-services.json` / iOS plist and the Gradle plugin).
3. `flutter pub get && flutter run`

Firestore layout: `users/{uid}` (name, email, settings), `users/{uid}/tasks`, `users/{uid}/sessions`.

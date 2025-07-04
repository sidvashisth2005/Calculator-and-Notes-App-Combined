# Combined Calculator & Notes App with Firebase Authentication

A cross-platform Flutter application that combines a simple Calculator and a Notes app, secured with Firebase Authentication and backed by Firestore for persistent note storage. This project demonstrates modern Flutter UI, authentication, and cloud integration.

---

## 🚀 Features

- **User Authentication**: Register and log in securely using email & password (Firebase Auth).
- **Calculator**: Perform basic arithmetic operations with a clean, responsive UI.
- **Notes App**: Create, edit, and delete notes. Notes are stored per user in Firestore.
- **Persistent Storage**: Notes are saved in the cloud and synced across devices.
- **Password Strength Meter**: Visual feedback during registration.
- **Logout**: Securely sign out from any device.
- **Responsive Design**: Works on Android, iOS, Web, Windows, macOS, and Linux.

---

## 📸 Screenshots

<img src="Screenshots/ss1%20%285%29.png" alt="Screenshot 5" width="200" /> <img src="Screenshots/ss1%20%284%29.png" alt="Screenshot 4" width="200" />

<img src="Screenshots/ss1%20%283%29.png" alt="Screenshot 3" width="200" /> <img src="Screenshots/ss1%20%282%29.png" alt="Screenshot 2" width="200" /> <img src="Screenshots/ss1%20%281%29.png" alt="Screenshot 1" width="200" />

 
 



---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.8.1 or higher recommended)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for project setup)
- A Firebase project (see below)

### 1. Clone the Repository
```bash
git clone https://github.com/sidvashisth2005/Calculator-and-Notes-App-Combined
cd Calculator-and-Notes-App-Combined
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
- Add Android, iOS, Web, and/or Desktop apps as needed.
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the respective folders:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- The project uses `lib/firebase_options.dart` generated by the FlutterFire CLI. If you change Firebase projects, regenerate this file:
  ```bash
  flutterfire configure
  ```
- Ensure your Firestore database is in **test mode** or set up appropriate security rules for development.

### 4. Run the App
```bash
flutter run
```
- For web: `flutter run -d chrome`
- For desktop: `flutter run -d windows` (or `macos`, `linux`)

---

## 🏗️ Project Structure

```
lib/
  main.dart                # App entry point, routing, and theme
  firebase_options.dart    # Firebase config (auto-generated)
  models/
    note_model.dart        # Note data model
  screens/
    login_screen.dart      # Login UI & logic
    registration_screen.dart # Registration UI & logic
    home_screen.dart       # Main menu (Calculator/Notes)
    calculator_screen.dart # Calculator UI & logic
    notes_screen.dart      # Notes UI & logic
  services/
    firebase_service.dart  # Auth & Firestore helpers
  utils/
    app_colors.dart        # Color palette
    button_values.dart     # Calculator button values
assets/
  images/                  # App logos (Google, GitHub)
```

---

## 🔒 Authentication & Security
- Email/password authentication is fully implemented.
- Google and GitHub sign-in are scaffolded but not yet implemented (see `login_screen.dart`).
- Password strength is checked during registration.
- User notes are stored per user in Firestore under `artifacts/default-app-id/users/{userId}/notes`.

---

## 📦 Dependencies
- `firebase_core`, `firebase_auth`, `cloud_firestore` — Firebase integration
- `flutter_bloc`, `hydrated_bloc`, `equatable` — State management
- `dio` — HTTP client (for future extensibility)
- `intl` — Internationalization
- `flutter_svg` — SVG asset support
- `cupertino_icons` — iOS-style icons

See [`pubspec.yaml`](pubspec.yaml) for the full list.

---

## 🧪 Testing
- Basic widget test included in `test/widget_test.dart`.
- Run all tests with:
```bash
flutter test
```

---

## 🤝 Contributing
1. Fork this repo
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements
- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Bloc](https://bloclibrary.dev/)

---

## 💡 Notes
- For production, update Firestore security rules and disable test mode.
- To enable Google or GitHub sign-in, follow the TODOs in `login_screen.dart` and add the required dependencies.
- If you encounter issues, check the [FlutterFire documentation](https://firebase.flutter.dev/docs/overview/).

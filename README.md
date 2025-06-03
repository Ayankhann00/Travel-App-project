# Travel-App-project

 Travel App - Flutter & Firebase
Travel App Banner

A beautiful travel community application built with Flutter and Firebase, where users can share their travel experiences, explore top destinations, and connect with fellow travelers.

✨ Features

User Authentication: Secure sign-up/login with Firebase Auth
Post Creation: Share travel experiences with photos and descriptions
Social Interactions: Like and comment on posts
Top Places: Discover popular travel destinations
Real-time Updates: Firebase Firestore for live data sync
Image Uploads: Store photos in Firebase Storage
Responsive UI: Beautiful design that works on all devices
🛠️ Tech Stack

Frontend: Flutter (Dart)
Backend: Firebase
Authentication
Firestore Database
Cloud Storage
State Management: Built-in Flutter State Management
Additional Packages:
cloud_firestore
firebase_auth
firebase_storage
image_picker
shared_preferences
📱 Screens

Home Screen	Add Post	Top Places
Home	Add Post	Top Places
🚀 Getting Started

Prerequisites

Flutter SDK (latest version)
Firebase account
Android Studio/Xcode (for emulator)
Physical device (optional but recommended)
Installation

Clone the repository
bash
git clone https://github.com/Ayankhann00/travel-app.git
cd travel-app
Set up Firebase
Create a new Firebase project
Add Android/iOS apps to your Firebase project
Download the configuration files:
google-services.json for Android
GoogleService-Info.plist for iOS
Place these files in the appropriate directories
Install dependencies
bash
flutter pub get
Run the app
bash
flutter run
🔧 Firebase Configuration

Enable Email/Password authentication in Firebase Console
Set up Firestore Database with these collections:
posts - For travel posts
users - For user profiles
Configure Firebase Storage rules for image uploads
📂 Project Structure

lib/
├── main.dart            # App entry point
├── pages/
│   ├── home.dart        # Main feed screen
│   ├── add_page.dart    # Post creation screen
│   ├── top_places.dart  # Popular destinations
│   ├── comment.dart     # Comments section
│   ├── signup.dart      # Authentication
│   └── notifications.dart # Notifications
├── services/
│   ├── database.dart    # Firebase operations
│   └── shared_pref.dart # Local storage
├── models/              # Data models
└── widgets/             # Reusable components
🤝 Contributing

Contributions are welcome! Please follow these steps:

Fork the project
Create your feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request
📄 License

Distributed under the MIT License. See LICENSE for more information.





Project Link: https://github.com/Ayankhann00/travel-app

Made with ❤️ by [Ayaan Khan]

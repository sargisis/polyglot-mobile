# Polyglot Mobile

**Polyglot Mobile** is a modern, cross-platform translation application built with Flutter. It provides seamless text translation capabilities with a clean, Material 3 design and offline support for translation history.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-757575?style=for-the-badge&logo=materialdesign&logoColor=white)

## ✨ Features

- **Text Translation**: Translate text between multiple languages.
- **Language Swapping**: Quickly swap between source and target languages.
- **Local History**: Save your translations locally (powered by Hive).
- **Clipboard Integration**: One-tap copy for translated text.
- **Modern UI**: Sleek interface following Material 3 design guidelines.
- **Cross-Platform**: Runs on Android, iOS, and Linux.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Local Storage**: [Hive](https://docs.hivedb.dev/)

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Android Studio / Xcode (for mobile development).
- Visual Studio / Build Tools (for desktop development).

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/polyglot-mobile.git
   cd polyglot-mobile
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   Connect a device or start an emulator, then run:
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                  # Application entry point
├── src/
│   ├── features/
│   │   └── translation/       # Translation feature module
│   │       ├── data/          # Repositories and Data Sources
│   │       ├── domain/        # Models (Language, Translation)
│   │       └── presentation/  # Screens and State Providers
│   └── core/                  # Core utilities and shared widgets
```

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

# 📚 TARL Mobile App

**Teaching at the Right Level (TARL) Parent Dashboard**

A modern, multilingual Flutter mobile application designed for parents to track their children's educational progress using the TARL methodology. This app provides comprehensive insights into test results, learning achievements, and educational analytics.

## 🌟 Features

### 📱 **Core Functionality**
- **Multilingual Support**: English, French, and Arabic with automatic RTL layout
- **Parent Authentication**: Secure login with role-based access control
- **Child Progress Tracking**: Real-time monitoring of educational achievements
- **Test Analytics**: Comprehensive view of test results and completion rates
- **Notifications**: Stay updated with your child's learning milestones
- **Dark/Light Theme**: Adaptive UI with system preference support

### 🎨 **Modern UI/UX**
- **Material Design 3**: Professional, accessible interface
- **Responsive Layout**: Optimized for various screen sizes
- **Custom Design System**: Consistent colors, typography, and components
- **Beautiful Animations**: Smooth transitions and interactions 
- **Error Handling**: Graceful error states with retry mechanisms

### 🔧 **Technical Features**
- **Firebase Integration**: Realtime Database, Authentication, Cloud Messaging
- **Offline Support**: Local caching with SharedPreferences
- **State Management**: Riverpod for scalable state handling
- **Localization**: Flutter's gen_l10n with ARB files
- **Performance**: Optimized for smooth 60fps experience

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: >= 3.16.0
- **Dart SDK**: >= 3.2.0
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Project** (optional for full functionality)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd TARL-mobile-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Configure Firebase (Optional)**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your project
   flutterfire configure
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── app/                          # App-level configuration
│   ├── localization/            # Locale and theme controllers
│   ├── theme/                   # Design system (colors, typography, themes)
│   ├── app.dart                 # Main app widget
│   ├── firebase_bootstrap.dart  # Firebase initialization
│   └── main.dart               # Entry point
├── common/                      # Shared components
│   ├── models/                 # Data models (Child, Parent, Test, Progress)
│   ├── services/               # Firebase services and repositories
│   └── widgets/                # Reusable UI components
├── features/                    # Feature-based modules
│   ├── auth/                   # Authentication (login, password change)
│   ├── home/                   # Dashboard and overview
│   ├── profile/                # User profile and settings
│   ├── students/               # Student profile views
│   ├── notifications/          # Alerts and notifications
│   ├── achievements/           # Progress and analytics
│   └── shell/                  # Main navigation shell
├── l10n/                       # Localization files
│   ├── app_en.arb             # English translations
│   ├── app_fr.arb             # French translations
│   ├── app_ar.arb             # Arabic translations
│   └── app_localizations.dart  # Generated localization code
└── assets/                     # Static assets
    └── decision_tree.json      # TARL decision tree data
```

## 🔧 Configuration

### Environment Setup

Create a `.env` file for environment-specific configuration:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key

# App Configuration
APP_NAME=TARL Parent Dashboard
APP_VERSION=1.0.0
```

### Firebase Setup

1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com)

2. **Enable required services**:
   - Realtime Database
   - Authentication
   - Cloud Messaging
   - Cloud Storage

3. **Configure security rules** for Realtime Database:
   ```json
   {
     "rules": {
       "users": {
         ".read": "auth != null",
         ".write": "auth != null"
       },
       "schools": {
         ".read": "auth != null"
       }
     }
   }
   ```

4. **Add platform configurations**:
   - Android: Add `google-services.json` to `android/app/`
   - iOS: Add `GoogleService-Info.plist` to `ios/Runner/`

## 📊 Data Models

### **Child Model**
```dart
class Child {
  final String id;
  final String firstName;
  final String lastName;
  final String preferredLanguage;
  final DateTime? birthDate;
  final Map<String, int> masteryLevels;
  final List<String> parentIds;
  // ... additional fields
}
```

### **Test Model**
```dart
class Test {
  final String id;
  final String childId;
  final String subject;
  final int difficulty;
  final TestStatus status;
  final int? score;
  final DateTime createdAt;
  // ... additional fields
}
```

### **Progress Model**
```dart
class ProgressRecord {
  final String id;
  final String childId;
  final String subject;
  final int levelBefore;
  final int levelAfter;
  final DateTime timestamp;
  // ... additional fields
}
```

## 🎨 Design System

### **Colors**
- **Primary**: Rich royal blue (`#1E3A8A`)
- **Secondary**: Modern teal (`#0891B2`)
- **Success**: Green (`#059669`)
- **Warning**: Orange (`#F59E0B`)
- **Error**: Red (`#DC2626`)

### **Typography**
- **Display**: Large headlines (32px, 28px, 24px)
- **Headline**: Section headers (22px, 20px, 18px)
- **Title**: Card titles (16px, 14px, 12px)
- **Body**: Content text (16px, 14px, 12px)
- **Label**: UI labels (14px, 12px, 10px)

### **Components**
- **AppCard**: Reusable card component with multiple variants
- **TarlLoading**: Branded loading indicator
- **TarlError**: Consistent error display

## 🌍 Internationalization

The app supports three languages with proper localization:

- **English** (`en`): Default language
- **French** (`fr`): Full translation support
- **Arabic** (`ar`): RTL layout with full translation

### Adding New Translations

1. **Add entries** to ARB files in `lib/l10n/`
2. **Regenerate** localization files:
   ```bash
   flutter gen-l10n
   ```
3. **Use** in widgets:
   ```dart
   final text = AppLocalizations.of(context)!;
   Text(text.welcomeMessage)
   ```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── models/             # Model tests
│   └── services/           # Service tests
├── widget/                 # Widget tests
│   └── features/           # Feature widget tests
└── integration/            # Integration tests
    └── app_test.dart       # Full app integration tests
```

## 🚀 Deployment

### Android

1. **Build APK**:
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Build iOS**:
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode** for App Store distribution

### Web (Optional)

```bash
flutter build web --release
```

## 📁 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1
  
  # Firebase
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.0
  firebase_database: ^12.0.0
  firebase_messaging: ^16.0.0
  firebase_storage: ^13.0.0
  
  # UI & Localization
  intl: ^0.20.2
  responsive_framework: ^1.5.1
  
  # Storage
  shared_preferences: ^2.5.3
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
```

## 🤝 Contributing

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/new-feature
   ```

2. **Follow code style**:
   ```bash
   flutter analyze
   dart format .
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Create pull request** with description of changes

### Code Style Guidelines

- **Use descriptive names** for variables and functions
- **Follow Dart conventions** (lowerCamelCase, etc.)
- **Add documentation** for public APIs
- **Write tests** for new features
- **Use const constructors** where possible
- **Organize imports** (dart, flutter, packages, relative)

## 🐛 Troubleshooting

### Common Issues

1. **Firebase not configured**:
   - Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is added
   - Run `flutterfire configure` to regenerate configuration

2. **Localization not working**:
   - Run `flutter gen-l10n` to regenerate localization files
   - Ensure ARB files are properly formatted

3. **Build errors**:
   - Clean build cache: `flutter clean && flutter pub get`
   - Check Flutter and Dart SDK versions

4. **State not updating**:
   - Ensure Riverpod providers are properly configured
   - Check widget rebuild conditions


**Built with ❤️ using Flutter and Firebase**

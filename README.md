# 📚 Books Tracker

A beautifully designed Flutter app for tracking your reading journey — built with **Clean Architecture**, **Riverpod** state management, and **local storage** via SharedPreferences.
---

## ✨ Features

- **Add & manage books** — title, author, genre, page count, cover emoji, and accent colour
- **Track reading progress** — drag a slider to update your current page
- **Reading status** — Currently Reading / Finished / Want to Read
- **Star ratings & notes** — rate finished books and write personal notes
- **Filter by status** — filter your library by reading state
- **Stats overview** — see reading, finished, and total counts at a glance
- **Persistent local storage** — all data saved to device via SharedPreferences
- **Delete books** — remove books with a confirmation dialog
- **Animated splash screen** — branded loading screen with staggered animations
- **Default seed data** — pre-loaded with sample books on first launch

---

## 🏛️ Architecture

This project follows **Clean Architecture** with four distinct layers, ensuring separation of concerns and testability.

```
lib/
├── core/
│   └── theme.dart                  # Design tokens, ThemeData
│
├── domain/                         # Pure Dart — no Flutter/package imports
│   ├── entities/
│   │   └── book.dart               # Book entity + ReadingStatus enum
│   └── repositories/
│       └── book_repository.dart    # Abstract repository contract
│
├── data/                           # Implements domain contracts
│   ├── models/
│   │   └── book_model.dart         # JSON serialisation / deserialisation
│   ├── datasources/
│   │   └── book_local_datasource.dart  # SharedPreferences read/write
│   └── repositories/
│       └── book_repository_impl.dart   # Bridges domain ↔ data
│
├── application/                    # Use cases — one class per action
│   └── usecases/
│       └── book_usecases.dart      # Get, Add, Update, Delete
│
├── presentation/                   # Flutter UI
│   ├── providers/
│   │   └── book_provider.dart      # Riverpod providers + filter state
│   └── screens/
│       ├── home_screen.dart        # Library list with stats & filters
│       ├── detail_screen.dart      # Book detail with progress & notes
│       └── add_book_screen.dart    # Add book form
│
└── main.dart                       # App entry, splash screen, DI setup
```

### Dependency rule

```
Presentation → Application → Domain ← Data
```

Domain knows nothing about Flutter, packages, or storage. Data implements the domain contract. Presentation talks only to Riverpod providers.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State management | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) ^2.5.1 |
| Local storage | [shared_preferences](https://pub.dev/packages/shared_preferences) ^2.2.2 |
| Splash screen | [flutter_native_splash](https://pub.dev/packages/flutter_native_splash) ^2.4.0 |
| Architecture | Clean Architecture (Domain / Data / Application / Presentation) |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter extension
- Android NDK `27.0.12077973` (for Android builds)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/HanHlaing/books_tracker.git
cd book_tracker

# 2. Install dependencies
flutter pub get

# 3. Generate native splash screen
dart run flutter_native_splash:create

# 4. Run the app
flutter run
```

### Android NDK note

If you see an NDK version mismatch error, add this to `android/app/build.gradle.kts`:

```kotlin
android {
    ndkVersion = "27.0.12077973"
    // ...
}
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  shared_preferences: ^2.2.2    # Local persistence
  flutter_native_splash: ^2.4.0 # Native splash screen

dev_dependencies:
  build_runner: ^2.4.8          # Code generation
  riverpod_generator: ^2.3.9    # Riverpod code gen
  flutter_native_splash: ^2.4.0 # Splash generation (CLI)
```

---

## 🎨 Design

The app uses a warm off-white editorial aesthetic:

- **Primary**: `#1A1A2E` — deep navy
- **Surface**: `#F8F5F0` — warm off-white
- **Typography**: Georgia serif for headings, system sans for body
- **Accent colours**: Per-book, user-selectable from 8 curated tones

---

## 🗂️ Data Flow

```
main.dart
  ├── SharedPreferences.getInstance()     // await before runApp
  ├── BookLocalDataSource.seedIfEmpty()   // first-launch defaults
  └── ProviderScope(overrides: [          // inject prefs into Riverpod
        sharedPrefsProvider ← prefs
      ])
        └── SplashScreen
              └── (watches bookListProvider)
                    └── HomeScreen
```

Each screen reads from `bookListProvider` (an `AsyncNotifier`) which calls use cases which call the repository which calls the local datasource — all in one direction, never skipping layers.

---

## 📱 Screens

| Screen | Description |
|---|---|
| **Splash** | Animated logo with pulsing dots; waits for data before navigating |
| **Home** | Stats cards, filter chips, book list with progress / ratings |
| **Detail** | Full book info, status toggle, page progress slider, star rating, notes |
| **Add Book** | Emoji picker, colour picker, form validation, status radio buttons |

---

## 🧪 Running Tests

```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgements

- [JSONPlaceholder](https://jsonplaceholder.typicode.com) — used for API practice examples
- [flutter_riverpod](https://riverpod.dev) — excellent state management documentation
- [pub.dev](https://pub.dev) — Flutter package ecosystem

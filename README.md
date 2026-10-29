# 💰 Flutter Personal Expense Tracker

A modern, responsive personal finance tracking application built with **Flutter** and **Dart**. Designed with a clean layered architecture, reactive state management using **Provider**, and persistent local browser storage via **SharedPreferences**.

---

## 🚀 Key Features

- **📊 Financial Analytics Dashboard**: Instant real-time overview of total expenditure, today's spending, transaction count, and monthly budget utilization.
- **🏷️ Categorization & Insights**: Visual multi-color budget breakdown across 6 core categories (*Food & Dining, Travel & Transport, Shopping, Bills & Utilities, Education, Other*).
- **🔎 Dynamic Filtering & Search**: Instant full-text search across titles and notes, combined with category filters and sorting by date or amount.
- **💾 Local Browser Persistence**: Automatically saves transactions and user profile preferences to browser local storage via `shared_preferences`.
- **🌱 Seeded Demo Experience**: Preloaded realistic sample transactions on initial launch with a one-click option to clear or reload demo data.
- **🌓 Adaptive Theme**: Full support for Light and Dark modes with Material 3 styling and responsive desktop/web layouts.
- **🛡️ Robust Input Validation**: Strict validation for monetary inputs, titles, and dates with user feedback dialogs and snackbars.

---

## 🏗️ Architecture & Project Structure

The project follows a modular, layered clean architecture:

```text
lib/
├── main.dart                                # Application entry point & theme setup
└── expense_tracker/
    ├── routes.dart                          # Centralized route definitions & route generator
    ├── models/
    │   ├── expense.dart                     # Expense entity & JSON serialization
    │   ├── expense_category.dart            # Category enum, display names, colors & icons
    │   └── app_user.dart                    # User profile, currency & budget settings
    ├── data/
    │   ├── expense_repository.dart          # Local storage repository & demo data seeding
    │   └── auth_repository.dart             # Local user preferences & budget persistence
    ├── providers/
    │   ├── expense_providers.dart           # Expense state, calculations & filtering
    │   ├── auth_providers.dart              # User profile & budget state
    │   └── app_providers.dart               # Theme management & MultiProvider registration
    ├── screens/
    │   ├── setup_check_screen.dart          # Initial bootstrap / loading screen
    │   ├── dashboard_screen.dart            # Metric cards, category breakdown & recent items
    │   ├── expense_list_screen.dart         # Full transaction ledger with search & filters
    │   ├── expense_detail_screen.dart       # Single transaction view & actions
    │   ├── expense_form_screen.dart         # Create & edit expense form
    │   └── not_found_screen.dart            # Fallback 404 handler
    ├── widgets/
    │   ├── summary_card.dart                # Budget progress & financial metrics widget
    │   ├── expense_card.dart                # Transaction tile with category badge
    │   └── category_filter.dart             # Horizontal category filter chips
    └── utils/
        ├── expense_validators.dart          # Form input validation rules
        └── app_messages.dart                # Snackbars, formatters & confirmation dialogs
```

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.32+
- **Language**: Dart 3.8+
- **State Management**: `provider: ^6.1.5`
- **Persistence**: `shared_preferences: ^2.5.3`
- **Formatting**: `intl: ^0.20.2`
- **Design System**: Material Design 3

---

## ⚡ Quick Start

### 1. Clone & Fetch Dependencies
```bash
git clone <repository-url>
cd ExpenseTracker
flutter pub get
```

### 2. Run Locally in Chrome
```bash
flutter run -d chrome
```

Or run via web server:
```bash
flutter run -d web-server --web-port=8080
```

### 3. Build for Production Web
```bash
flutter build web --release
```

The output bundle is generated at `build/web/`, ready to deploy to GitHub Pages, Firebase Hosting, Netlify, or Vercel.

---

## 🧪 Testing

Run all unit and widget tests:
```bash
flutter test
```

Run pure Dart model & validator tests:
```bash
dart test test/expense_model_test.dart test/expense_validator_test.dart
```

---

## 📄 License
MIT License. Created for technical portfolio & resume showcase.

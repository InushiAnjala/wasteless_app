# 🌿 WasteLess — Smart Food Inventory & Waste Reduction App

> **A Flutter & Firebase mobile application designed to help restaurants and food businesses minimise food waste through intelligent inventory tracking, expiry alerts, AI-powered recipe suggestions, and actionable analytics.**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [User Roles](#user-roles)
- [Screenshots & Screens](#screenshots--screens)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Contributors](#contributors)

---

## Overview

**WasteLess** is a cross-platform mobile application built with Flutter that empowers food service businesses — restaurants, catering services, and commercial kitchens — to actively manage their food inventory and drastically reduce unnecessary food waste.

The app provides a role-based experience for three distinct user types: **Store Managers**, **Chefs**, and **Administrators**. Each role has a tailored dashboard and feature set that supports real-time collaboration and informed decision-making around food stock.

---

## Key Features

### 🔐 Authentication & Onboarding
- Email/password sign-up and login via **Firebase Authentication**
- Guided multi-step **onboarding flow** with illustrated screens
- **Forgot password** flow with Firebase email reset
- Role-based routing after login — each user lands on their dedicated dashboard

### 📦 Inventory Management (Store Manager)
- Add food items with name, category, quantity, unit, and **expiry date**
- View the complete food inventory with live Firestore sync
- Visual **colour-coded expiry indicators** (fresh → expiring soon → expired)
- Edit and delete items directly from the food list
- OCR-based label scanning to pre-fill food item details (via **Google ML Kit**)

### 🔔 Smart Notifications
- **Daily scheduled push notifications** at a user-configured time (powered by `flutter_local_notifications`)
- Alerts for items expiring **today**, **tomorrow**, and within the **next 3 days**
- Customisable notification preferences screen (enable/disable, set delivery time)
- In-app **notification centre** displaying a history of recent alerts

### ⚠️ Expiry & Stock Alerts
- Dedicated **Alert Screen** consolidating all items nearing expiry or already expired
- **Low Stock** screen listing items below a configurable threshold
- **Expired Items** screen for items that have passed their use-by date
- **Kitchen Needs** screen for items that require restocking

### 🤖 AI Chef Assistant (Chef Role)
- Browse all available in-stock ingredients from the live inventory
- **Voice input** support for querying recipes (via `speech_to_text`)
- AI-generated recipe suggestions using **Google Gemini (Generative AI)**  
- Detailed recipe view with ingredients, step-by-step instructions, and tips
- **Save recipes** for offline reference in a personal recipe library
- Flag ingredients as **Not in Stock** for manager awareness
- **Manual recipe** entry and browsing screen

### 📊 Analytics & Reporting (Store Manager)
- Interactive **fl_chart** powered dashboards showing:
  - Waste trends over time
  - Category-wise stock distribution
  - Expiry timeline heatmap
- **Date-range filtering** for custom report windows
- Export analytics as a **PDF report** (via `pdf` + `printing` packages)
- Downloadable reports saved to device via `path_provider`

### 🛠 Admin Panel
- High-level system overview for administrators
- User management and system health monitoring

---

## User Roles

| Role | Dashboard | Core Access |
|---|---|---|
| **Store Manager** | Home Screen | Inventory, Alerts, Notifications, Reports |
| **Chef** | Chef Main Screen | Inventory View, AI Recipes, Saved Recipes, Not-in-Stock |
| **Admin** | Admin Home Screen | System Overview, User Management |

Role assignment is stored in **Cloud Firestore** and read at login to route users to the correct experience.

---

## Screenshots & Screens

### Authentication Flow
| Onboarding | Login | Sign Up | Forgot Password |
|---|---|---|---|
| `onboarding_screen.dart` | `login_screen.dart` | `signup_screen.dart` | `forgot_password_screen.dart` |

### Store Manager Flow
| Home Dashboard | Food List | Add Food Item | Expiry Alerts |
|---|---|---|---|
| `home_screen.dart` | `food_list_screen.dart` | `add_food_screen.dart` | `alert_screen.dart` |

| Low Stock | Expired Items | Reports | Notifications |
|---|---|---|---|
| `low_stock_items_screen.dart` | `expired_items_screen.dart` | `reports_screen.dart` | `notifications_screen.dart` |

### Chef Flow
| Chef Home | Food Browser | AI Recipe Generator | Saved Recipes |
|---|---|---|---|
| `chef_home_screen.dart` | `chef_food_screen.dart` | `ai_screen.dart` | `saved_recipes_screen.dart` |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) — SDK `^3.10.1` |
| **Backend / Database** | Firebase (Firestore, Auth, Cloud Functions) |
| **AI / ML** | Google Gemini API (`google_generative_ai`) |
| **OCR** | Google ML Kit Text Recognition |
| **Charts** | fl_chart |
| **Notifications** | flutter_local_notifications + timezone |
| **PDF Export** | pdf + printing |
| **Voice Input** | speech_to_text |
| **Fonts** | Google Fonts |
| **State Management** | Flutter built-in (`setState`, `StreamBuilder`) |

---

## Architecture

```
lib/
├── main.dart                    # App entry point, Firebase init, notification setup
├── firebase_options.dart        # Auto-generated Firebase config
├── constants/                   # App-wide constants (colours, strings, etc.)
├── screens/
│   ├── auth/                    # Login, Sign Up, Forgot Password, OTP, Auth Wrapper
│   ├── home/                    # Store Manager screens (inventory, alerts, reports)
│   ├── chef/                    # Chef screens (recipe AI, food browser, saved recipes)
│   ├── admin/                   # Admin dashboard
│   └── onboarding/              # Onboarding flow
├── services/
│   ├── notification_service.dart  # Local notification scheduling & management
│   └── report_service.dart        # PDF report generation & export
├── utils/                       # Helper functions and utilities
└── widgets/                     # Reusable UI components
```

**Data Flow:**
- All food inventory data is stored and synced in real-time via **Cloud Firestore**
- **Firebase Auth** handles session management and role claims
- **Cloud Functions** handle server-side operations (e.g., data aggregation)
- Notifications are scheduled locally on-device using `flutter_local_notifications`

---

## Getting Started

### Prerequisites

Ensure the following are installed on your machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.10.1`
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extension
- A connected Android/iOS device or emulator
- A [Firebase project](https://console.firebase.google.com/) with Firestore and Authentication enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/InushiAnjala/wasteless_app.git
   cd wasteless_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (see [Firebase Setup](#firebase-setup) below)

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## Firebase Setup

1. Create a project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Email/Password provider)
3. Enable **Cloud Firestore** in your region
4. (Optional) Enable **Cloud Functions** for server-side logic
5. Download the `google-services.json` file and place it in `android/app/`
6. Download the `GoogleService-Info.plist` file and place it in `ios/Runner/`
7. Run `flutterfire configure` to regenerate `firebase_options.dart` if needed

### Firestore Security Rules

Basic rules are provided in `firestore.rules`. Review and tighten them before any production deployment.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `firebase_core` | ^3.6.0 | Firebase initialisation |
| `firebase_auth` | ^5.1.0 | User authentication |
| `cloud_firestore` | ^5.4.0 | Real-time NoSQL database |
| `cloud_functions` | ^5.4.0 | Server-side Cloud Functions |
| `google_generative_ai` | ^0.4.7 | Gemini AI recipe generation |
| `google_mlkit_text_recognition` | ^0.14.0 | OCR for food label scanning |
| `fl_chart` | ^0.69.0 | Analytics charts |
| `flutter_local_notifications` | ^18.0.0 | Scheduled push notifications |
| `timezone` | ^0.9.4 | Timezone handling for notifications |
| `speech_to_text` | ^7.0.0 | Voice input for recipe queries |
| `pdf` | ^3.12.0 | PDF report generation |
| `printing` | ^5.14.3 | Print/share PDF reports |
| `path_provider` | ^2.1.5 | File system access for exports |
| `image_picker` | ^1.1.2 | Camera/gallery image selection |
| `google_fonts` | ^6.2.1 | Custom typography |
| `intl` | ^0.19.0 | Date/number formatting |

---

## Contributors

| Name | Role |
|---|---|
| **Inushi Anjala** | Lead Developer — Full Stack Flutter & Firebase |

---

## Licence

This project was developed as a **Final Year Project** for academic submission. All rights reserved © 2026.

---

*Built with 💚 to make the world a little less wasteful.*

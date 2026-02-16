# Aaliyah's Collection – Modest Fashion E-Store

[![Flutter Version](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20%2F%20MVC-brightgreen)](#folder-structure)
[![License](https://img.shields.io/badge/License-GPL--3.0-blue)](https://choosealicense.com/licenses/gpl-3.0/)

**Aaliyah's Collection** is a premium, fully functional mobile application dedicated to modest fashion. Built using **Flutter**, it offers a seamless shopping experience with real-time API integration, secure multi-factor authentication, and advanced mobile hardware capabilities.

This project was developed for the **COMP50011: Mobile App Development II** module at Staffordshire University.

---

## 📖 Table of Contents
- [Project Motivation](#-project-motivation)
- [Key Features](#-key-features)
- [Architecture & State Management](#-architecture--state-management)
- [Mobile Device Capabilities](#-mobile-device-capabilities)
- [Tech Stack](#-tech-stack)
- [Installation & Setup](#-installation--setup)
- [Folder Structure](#-folder-structure)

---

## 🎯 Project Motivation
The goal was to move beyond a simple mock-up and build a production-ready e-commerce solution that balances aesthetics with robust engineering:
*   **Connectivity:** Ensuring the app remains usable even without internet (using Local JSON fallbacks).
*   **Security:** Implementing industry-standard authentication like Google Sign-In, 2FA, and Biometrics.
*   **Accessibility:** Adapting UI based on ambient light and system accessibility settings.

---

## ✨ Key Features

### 🔐 Advanced Authentication
*   **Multi-Source Login:** Authenticate via Laravel API (SSP Module) or Firebase (Google Sign-In).
*   **Two-Factor Authentication (2FA):** Enhanced account security with 6-digit verification codes using `Pinput`.
*   **Biometric Login:** Fast, secure access using Fingerprint/Face recognition via `local_auth`.

### 🛍️ Premium Shopping Experience
*   **Dynamic Shop:** Browse, filter by category (Abayas, Hijabs, etc.), and sort by price or date.
*   **Intelligent Search:** Text-based search or **Voice Search** for a hands-free experience.
*   **Cart & Wishlist:** Persistent local storage using **Sqflite** with a premium "Fly to Cart" animation.
*   **Offline Mode:** Automatic switch to local assets when internet connectivity is lost, ensuring zero downtime.

### 📦 Order & Personalization
*   **Checkout Workflow:** 3-step process involving address (with GPS auto-fill), payment mode, and order review.
*   **Invoice Generation:** Professional PDF invoices generated instantly upon order completion.
*   **Order Tracking:** View order history and detailed status updates fetched from a live API.

---

## ⚙️ Architecture & State Management
The project follows a **Feature-First Architecture** with an **MVC (Model-View-Controller)** pattern inside each domain to ensure high scalability and testability.

*   **State Management:** Powered by **Provider**.
*   **Why Provider?** It allows for efficient scoped state updates (e.g., updating the cart badge without rebuilding the entire UI) and provides a clean separation between business logic and the presentation layer.

---

## 📱 Mobile Device Capabilities
This app showcases advanced hardware integration required for Level 5 development:
*   **Theme Adaptation:** Supports System-native Light/Dark modes with accessible color schemes.
*   **Ambient Light Sensor:** Automatically adjusts screen brightness based on environment lighting.
*   **Geolocation & Geocoding:** Uses GPS to auto-fill delivery addresses during checkout.
*   **Microphone:** Integrated into the search bar for **Speech-to-Text** functionality.
*   **Connectivity Monitoring:** Real-time listeners via `connectivity_plus` to notify users of network status changes.

---

## 🛠️ Tech Stack
*   **Framework:** Flutter (Dart)
*   **Database:** Cloud Firestore (Sync), SQLite / Sqflite (Local Cache)
*   **Storage:** Shared Preferences (UI Settings), Flutter Secure Storage (Auth Tokens)
*   **Networking:** Dio (API Client with Interceptors)
*   **Payments:** Flutter Stripe Integration
*   **UI/UX:** Google Fonts, Shimmer, Carousel Slider, Animate Do, ScreenUtil

---

## 🚀 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/salmamuzam/aaliyahs-collection-app.git](https://github.com/salmamuzam/aaliyahs-collection-app.git)
   Install dependencies:
   ## Install dependencies:
```bash
flutter pub get
```

## Setup Environment Variables:
Create an `assets/.env` file and add your API credentials:

```env
STRIPE_PUBLISHABLE_KEY=your_key_here
API_BASE_URL=your_laravel_api_url
```

## Run the application:
```bash
flutter run
```

---

## 📂 Folder Structure
```text
lib/
├── common/              # Reusable UI widgets, loaders, and navigation menu
├── data/                # Repositories handling API vs Local logic
├── features/            # Feature-First Business Domains
│   ├── authentication/  # Login, Signup, Onboarding, 2FA
│   ├── personalization/ # Profile, User Settings, Sensor logic
│   └── shop/            # Catalog, Home, Cart, Checkout, Orders
├── routes/              # Centralized route management
└── utils/               # Handlers for Device, Theme, Formatting & Dio
```


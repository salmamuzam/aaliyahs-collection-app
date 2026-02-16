# Aaliyah's Collection – Modest Fashion E-Store

[![Flutter Version](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20%2F%20MVC-brightgreen)](#folder-structure)

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

- **Connectivity:** Ensuring the app remains usable even without internet (using Local JSON fallbacks).  
- **Security:** Implementing industry-standard authentication like Google Sign-In, 2FA, and Biometrics.  
- **Accessibility:** Adapting UI based on ambient light and system accessibility settings.  

---

## ✨ Key Features

### 🔐 Advanced Authentication
- **Multi-Source Login:** Authenticate via Laravel API (SSP Module) or Firebase (Google Sign-In).  
- **Two-Factor Authentication (2FA):** 6-digit verification codes using `Pinput`.  
- **Biometric Login:** Fingerprint/Face recognition via `local_auth`.  

### 🛍️ Premium Shopping Experience
- **Dynamic Shop:** Browse, filter by category, sort by price or date.  
- **Intelligent Search:** Text-based or **Voice Search**.  
- **Cart & Wishlist:** Persistent local storage with **Sqflite**, premium "Fly to Cart" animation.  
- **Offline Mode:** Switch to local assets when offline.  

### 📦 Order & Personalization
- **Checkout Workflow:** 3-step process: address (with GPS auto-fill), payment, review.  
- **Invoice Generation:** Instant professional PDF invoices.  
- **Order Tracking:** Live API order status updates.  

---

## ⚙️ Architecture & State Management
- **Architecture:** Feature-First with MVC per domain.  
- **State Management:** **Provider** for scoped updates and separation of UI & logic.  

---

## 📱 Mobile Device Capabilities
- **Theme Adaptation:** Supports Light/Dark mode with accessible colors.  
- **Ambient Light Sensor:** Auto screen brightness adjustment.  
- **Geolocation & Geocoding:** GPS auto-fill for delivery.  
- **Microphone:** Speech-to-Text in search.  
- **Connectivity Monitoring:** Real-time network status via `connectivity_plus`.  

---

## 🛠️ Tech Stack
- **Framework:** Flutter (Dart)  
- **Database:** Cloud Firestore (Sync), SQLite / Sqflite (Local Cache)  
- **Storage:** Shared Preferences, Flutter Secure Storage  
- **Networking:** Dio with interceptors  
- **Payments:** Flutter Stripe Integration  
- **UI/UX:** Google Fonts, Shimmer, Carousel Slider, Animate Do, ScreenUtil  

---

## 🚀 Installation & Setup

### 1️⃣ Clone the repository
```bash
git clone https://github.com/salmamuzam/aaliyahs-collection-app.git
cd aaliyahs-collection-app
```

### 2️⃣ Install dependencies
```bash
flutter pub get
```

### 3️⃣ Setup Environment Variables
Create an `assets/.env` file:
```env
STRIPE_PUBLISHABLE_KEY=your_key_here
API_BASE_URL=your_laravel_api_url
```

### 4️⃣ Run the application
```bash
flutter run
```

---

## 📂 Folder Structure
```text
lib/
├── common/              # Reusable UI widgets, loaders, navigation menu
├── data/                # Repositories handling API vs Local logic
├── features/            # Feature-First Business Domains
│   ├── authentication/  # Login, Signup, Onboarding, 2FA
│   ├── personalization/ # Profile, User Settings, Sensor logic
│   └── shop/            # Catalog, Home, Cart, Checkout, Orders
├── routes/              # Centralized route management
└── utils/               # Handlers for Device, Theme, Formatting & Dio
```

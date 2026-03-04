# AgriSmart Farmer MVP

AgriSmart Farmer is a modern Flutter mobile application designed to empower farmers with tools for disease detection, a local marketplace, and high-quality e-learning resources.

## 🚀 Features

- **Plant Scan**: Detect plant diseases using AI (Mock) with confidence scores and treatment recommendations.
- **Marketplace**: A streamlined interface to buy and sell seeds, fertilizers, and tools.
- **Dashboard**: A comprehensive overview of field health, active alerts, and sales statistics.
- **E-Learning**: Video and document-based courses to improve farming techniques.
- **Authentication**: Secure login and profile management for farmers.

## 🛠 Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Storage**: Hive & SharedPreferences
- **Networking**: Dio
- **Design**: Clean Architecture (Feature-first)
- **UI**: Custom components, Google Fonts (Outfit), fl_chart

## 📦 Getting Started

1. **Clone the repository** (if applicable).
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run code generation** (Freezed & Riverpod):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. **Launch the app**:
   ```bash
   flutter run
   ```

## 📂 Project Structure

- `lib/core`: Foundation (Networking, Theme, Storage).
- `lib/features`: Scoped modules (Auth, Dashboard, Scan, Marketplace, Learning).
- `lib/shared`: Reusable widgets and common models.
- `assets`: Media resources.


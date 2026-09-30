# SIGNAL - Flutter Responsive WebView App

A responsive Flutter mobile and web application designed to load the live public web experience at:
`https://transcendent-donut-73e53f.netlify.app` (*SIGNAL: An Empathia Learn Story*).

---

## 🚀 Key Features

- **Responsive & Adaptive**: Seamlessly scales across phones, foldables, tablets, and web displays in both portrait and landscape orientations.
- **Themed UI**: Built with a cyberpunk / graphic-novel palette (`#070B14`, cyan `#22D3EE`, and magenta `#EC4899`) perfectly matching the website.
- **Immersive Fullscreen Reader**: One-tap toggle into fullscreen mode hiding system bars for distraction-free reading.
- **Hardware & Gesture Back Navigation**: Intercepts Android back gestures via Flutter's `PopScope` to navigate backward in web history before confirming exit.
- **Pull-To-Refresh**: Native `RefreshIndicator` support to reload content on drag down.
- **Real-Time Offline & Connectivity Monitoring**: Live connection listening via `connectivity_plus`, showing an offline banner and offering instant auto/manual retry.
- **Progress & Error States**: Sleek progress bar showing real-time load progress and branded error screens for transmission interruptions.
- **External URL Handling**: External schemes (`mailto:`, `tel:`, non-HTTP links) are opened safely using `url_launcher`.
- **Platform Resilience**: Gracefully handles desktop and testing environments with fallback view.

---

## 🛠️ Project Structure

```
lib/
├── config/
│   └── constants.dart         # Colors, theme variables, and target URL
├── screens/
│   └── webview_screen.dart    # Main screen with WebViewWidget, PopScope, and toolbar
├── services/
│   └── connectivity_service.dart # Real-time network status stream
├── widgets/
│   ├── desktop_view.dart      # Fallback UI for desktop/headless targets
│   ├── error_view.dart        # Offline & error state UI with retry
│   ├── loading_overlay.dart   # Initial splash & linear progress bar
│   └── webview_toolbar.dart   # Navigation bar (Back, Forward, Reload, Fullscreen, Open external)
└── main.dart                  # App bootstrap, dark theme & system UI overlays
```

---

## 📱 Running the App

### 1. Run on Chrome / Web
```bash
flutter run -d chrome
```

### 2. Run on Android Device / Emulator
Ensure an Android device or emulator is running:
```bash
flutter run -d android
```

### 3. Build Production APK / App Bundle
```bash
# Build APK
flutter build apk --release

# Build App Bundle for Google Play
flutter build appbundle --release
```

### 4. Run Tests
```bash
flutter test
```

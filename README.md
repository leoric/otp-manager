# OTPManager for macOS

OTPManager is a native macOS menu bar application built with **SwiftUI** for managing Time-based One-Time Passwords (TOTP). Designed for speed and minimal UI footprint, it lives exclusively in the macOS Menu Bar and supports global hotkey triggers, QR code imports, and quick-editing capabilities.

---

## Features

- **Menu Bar Resident**: Runs silently in the menu bar with no Dock icon (`LSUIElement`).
- **Quick Access & Esc-to-Dismiss**: Left-clicking the menu bar icon toggles the popover view. Pressing `Esc` instantly hides active popovers and modal windows.
- **Global Hotkey**: Configurable shortcut (defaults to `Cmd + Option + Space`) to show/hide the application from anywhere.
- **QR Code Import**: Simple file picker dialog to import accounts from saved QR code images (`otpauth://` format).
- **Manual Account Management**:
  - Add TOTP accounts manually with custom parameters (Issuer, Name, Secret key, Period, Digits, SHA algorithm).
  - In-place renaming for Issuer and Name in edit mode.
  - Reordering accounts with drag-and-drop handles in edit mode.
- **Strict Base32 Validation**: Auto-formats secret keys to uppercase, ignores whitespace, and validates allowed characters (`A-Z`, `2-7`) before saving.
- **ARM64 Alignment Safe**: Native TOTP calculation optimized for Apple Silicon without memory alignment crashes.
- **Right-Click Context Menu**: Right-clicking the menu bar icon opens quick options for Settings and Quit.

---

## Requirements

- **macOS 13.0** (Ventura) or later
- **Swift 5.9+** Command Line Tools (`swift --version`)

---

## Project Structure

```text
OTPManager/
├── Package.swift
├── README.md
├── Sources/
│   └── OTPManager/
│       ├── App/
│       │   ├── OTPManagerApp.swift
│       │   ├── AppDelegate.swift
│       │   ├── WindowManager.swift
│       │   ├── HotKeyManager.swift
│       │   └── ValidationCheck.swift
│       ├── Models/
│       │   └── OTPAccount.swift
│       ├── Services/
│       │   ├── OTPGenerator.swift
│       │   └── StorageManager.swift
│       ├── Views/
│       │   ├── MainView.swift
│       │   ├── AccountRowView.swift
│       │   ├── AddAccountView.swift
│       │   ├── EditAccountView.swift
│       │   ├── SettingsView.swift
│       │   └── Components/
│       │       ├── AddMenuPopoverView.swift
│       │       └── CustomCircularProgressView.swift
│       └── Resources/
│           └── AppIcon.icns
└── Tests/
    └── OTPManagerTests/
        ├── HotKeyManagerTests.swift
        └── OTPAccountTests.swift
```

---

## Building and Running via Command Line Tools (CLT)

### 1. Build the Debug Executable
```bash
swift build
```

### 2. Run the Application
```bash
swift run
```

### 3. Check and Compile Tests
To check type correctness and verify that both the app and test targets compile cleanly:
```bash
swift build --build-tests
```

---

## Creating a macOS Application Bundle (.app)

To package the project into a standalone macOS `.app` bundle with the embedded application icon:

```bash
# 1. Build Release Executable
swift build -c release

# 2. Create App Bundle Directory Structure
mkdir -p OTPManager.app/Contents/MacOS
mkdir -p OTPManager.app/Contents/Resources

# 3. Copy Executable and Icon Resources
cp .build/release/OTPManager OTPManager.app/Contents/MacOS/
cp Sources/OTPManager/Resources/AppIcon.icns OTPManager.app/Contents/Resources/

# 4. Generate Info.plist
cat <<EOF > OTPManager.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>OTPManager</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.OTPManager</string>
    <key>CFBundleName</key>
    <string>OTPManager</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# 5. Launch Application Bundle
open OTPManager.app
```

---

## License

MIT License. Free to use and modify.
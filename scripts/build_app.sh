swift build -c release

mkdir -p OTPManager.app/Contents/MacOS
mkdir -p OTPManager.app/Contents/Resources

cp .build/release/OTPManager OTPManager.app/Contents/MacOS/
cp Sources/OTPManager/Resources/AppIcon.icns OTPManager.app/Contents/Resources/

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

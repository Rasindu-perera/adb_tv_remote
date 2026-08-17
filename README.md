# KWR TV Remote 📺

A highly optimized Android TV remote application built with Flutter. Designed specifically for low-resource smart TVs, it uses ADB over Wi-Fi to deliver ultra-fast, zero-latency control without requiring any background apps on the TV.

## Key Features

- ⚡ **Zero Latency:** Direct ADB shell command execution.
- 🖱️ **Virtual Trackpad:** Smooth mouse control with built-in event throttling.
- 🔍 **Auto-Discovery:** Automatically scans the local subnet to find your TV's IP.
- ⌨️ **Direct Keyboard:** Type on your phone and send text directly to the TV.
- 🎮 **Essential Controls:** D-pad, Volume, Power, and dedicated Media Player buttons.
- 💾 **Auto-Save:** Remembers your last successfully connected IP address for quick access.
- ℹ️ **Help Guide:** Built-in instructions on how to enable Developer Options and ADB Network Debugging on your Android TV.

## Getting Started

### Prerequisites
- Flutter SDK `^3.6.0`
- Both your device running the app and the TV must be on the same Wi-Fi network.

### Setup your TV for ADB
1. Go to your TV's **Settings > Device Preferences > About**.
2. Scroll down to **Build Number** and click it 7 times to unlock Developer Options.
3. Go back and open **Developer Options**.
4. Enable **USB Debugging** and **Network Debugging**.
5. When the app connects for the first time, check your TV screen to **Allow USB debugging** from your device's RSA key.

### Running the App
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run the app using `flutter run` on your preferred device.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

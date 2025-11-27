# flutter_advanced_haptic

English | [한국어](https://github.com/flxh4894/flutter_advanced_haptic/blob/main/translations/ko-KR.md)

A Flutter plugin for advanced haptic feedback with customizable intensity, duration, and WebView bridge support.

## Features

- Preset haptic feedback (light, medium, heavy, short, long, success, warning, error)
- Custom vibration with adjustable intensity (0.0-1.0) and duration
- Pattern playback (sequences of vibrations and pauses)
- WebView JavaScript bridge for haptic feedback from web content
- iOS 16+ and Android SDK 26+ support

## Installation

```bash
flutter pub add flutter_advanced_haptic
```

### Android

Add vibrate permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

### iOS

No additional setup required. Uses Core Haptics framework (iOS 16+).

## Usage

### Basic Usage

```dart
import 'package:flutter_advanced_haptic/flutter_advanced_haptic.dart';

final haptic = FlutterHaptic.instance;

// Presets
await haptic.light();
await haptic.medium();
await haptic.heavy();
await haptic.short();
await haptic.long();
await haptic.success();
await haptic.warning();
await haptic.error();

// Custom vibration
await haptic.vibrate(
  intensity: 0.7,  // 0.0 to 1.0
  duration: 100,   // milliseconds
);

// Check device support
bool isSupported = await haptic.isSupported();
bool supportsIntensity = await haptic.supportsIntensity();
```

### Pattern Playback

```dart
// Built-in patterns
await haptic.playPattern(HapticPattern.doubleTap());
await haptic.playPattern(HapticPattern.tripleTap());
await haptic.playPattern(HapticPattern.heartbeat());

// Custom pattern
await haptic.playPattern(
  HapticPattern.custom(
    pattern: [100, 50, 200, 100, 50],  // vibrate, pause, vibrate, pause, vibrate
    intensities: [0.3, 0.6, 0.9],       // intensity for each vibration
  ),
);

// Manual pattern construction
await haptic.playPattern(
  HapticPattern([
    HapticEvent.vibrate(duration: 50, intensity: 0.5),
    HapticEvent.pause(30),
    HapticEvent.vibrate(duration: 50, intensity: 0.5),
  ]),
);

// Cancel ongoing haptic
await haptic.cancel();
```

### WebView Bridge

Use haptic feedback from JavaScript in a WebView:

```dart
import 'package:flutter_advanced_haptic/flutter_advanced_haptic.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebViewPage extends StatefulWidget {
  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late final WebViewController _controller;
  final HapticWebViewBridge _bridge = HapticWebViewBridge();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        _bridge.channelName,
        onMessageReceived: (message) {
          _bridge.handleMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            await _controller.runJavaScript(_bridge.getInjectionScript());
          },
        ),
      )
      ..loadRequest(Uri.parse('https://example.com'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
```

In your web content (JavaScript):

```javascript
// Presets
FlutterHaptic.light();
FlutterHaptic.medium();
FlutterHaptic.heavy();
FlutterHaptic.success();
FlutterHaptic.warning();
FlutterHaptic.error();

// Custom vibration
FlutterHaptic.vibrate({
  intensity: 0.7,
  duration: 100
});

// Pattern
FlutterHaptic.pattern([
  { duration: 50, intensity: 0.5 },
  { duration: 30, intensity: 0 },    // pause
  { duration: 50, intensity: 0.5 }
]);

// Cancel
FlutterHaptic.cancel();
```

## Platform Support

| Feature | iOS | Android |
|---------|-----|---------|
| Presets | Core Haptics / UIFeedbackGenerator | VibrationEffect |
| Custom Intensity | Core Haptics | VibrationEffect (API 26+) |
| Custom Duration | Core Haptics | VibrationEffect |
| Pattern Playback | Core Haptics | VibrationEffect.createWaveform |
| Intensity Control Check | CHHapticEngine.capabilities | Vibrator.hasAmplitudeControl |

## Requirements

- iOS 16.0+
- Android SDK 26+
- Flutter 3.10+

## License

MIT License

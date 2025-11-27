# flutter_advanced_haptic

[English](../README.md) | 한국어

강도, 지속시간 조절 및 WebView 브릿지를 지원하는 고급 햅틱 피드백 Flutter 플러그인입니다.

## 기능

- 프리셋 햅틱 피드백 (light, medium, heavy, short, long, success, warning, error)
- 강도(0.0-1.0)와 지속시간을 조절할 수 있는 커스텀 진동
- 패턴 재생 (진동과 일시정지의 시퀀스)
- 웹 콘텐츠에서 햅틱 피드백을 위한 WebView JavaScript 브릿지
- iOS 16+ 및 Android SDK 26+ 지원

## 설치

```bash
flutter pub add flutter_advanced_haptic
```

### Android

`android/app/src/main/AndroidManifest.xml`에 진동 권한 추가:

```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

### iOS

추가 설정이 필요 없습니다. Core Haptics 프레임워크를 사용합니다 (iOS 16+).

## 사용법

### 기본 사용법

```dart
import 'package:flutter_advanced_haptic/flutter_advanced_haptic.dart';

final haptic = FlutterHaptic.instance;

// 프리셋
await haptic.light();
await haptic.medium();
await haptic.heavy();
await haptic.short();
await haptic.long();
await haptic.success();
await haptic.warning();
await haptic.error();

// 커스텀 진동
await haptic.vibrate(
  intensity: 0.7,  // 0.0 ~ 1.0
  duration: 100,   // 밀리초
);

// 기기 지원 여부 확인
bool isSupported = await haptic.isSupported();
bool supportsIntensity = await haptic.supportsIntensity();
```

### 패턴 재생

```dart
// 내장 패턴
await haptic.playPattern(HapticPattern.doubleTap());
await haptic.playPattern(HapticPattern.tripleTap());
await haptic.playPattern(HapticPattern.heartbeat());

// 커스텀 패턴
await haptic.playPattern(
  HapticPattern.custom(
    pattern: [100, 50, 200, 100, 50],  // 진동, 일시정지, 진동, 일시정지, 진동
    intensities: [0.3, 0.6, 0.9],       // 각 진동의 강도
  ),
);

// 수동 패턴 구성
await haptic.playPattern(
  HapticPattern([
    HapticEvent.vibrate(duration: 50, intensity: 0.5),
    HapticEvent.pause(30),
    HapticEvent.vibrate(duration: 50, intensity: 0.5),
  ]),
);

// 진행 중인 햅틱 취소
await haptic.cancel();
```

### WebView 브릿지

WebView에서 JavaScript로 햅틱 피드백 사용:

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

웹 콘텐츠에서 (JavaScript):

```javascript
// 프리셋
FlutterHaptic.light();
FlutterHaptic.medium();
FlutterHaptic.heavy();
FlutterHaptic.success();
FlutterHaptic.warning();
FlutterHaptic.error();

// 커스텀 진동
FlutterHaptic.vibrate({
  intensity: 0.7,
  duration: 100
});

// 패턴
FlutterHaptic.pattern([
  { duration: 50, intensity: 0.5 },
  { duration: 30, intensity: 0 },    // 일시정지
  { duration: 50, intensity: 0.5 }
]);

// 취소
FlutterHaptic.cancel();
```

## 플랫폼 지원

| 기능 | iOS | Android |
|------|-----|---------|
| 프리셋 | Core Haptics / UIFeedbackGenerator | VibrationEffect |
| 커스텀 강도 | Core Haptics | VibrationEffect (API 26+) |
| 커스텀 지속시간 | Core Haptics | VibrationEffect |
| 패턴 재생 | Core Haptics | VibrationEffect.createWaveform |
| 강도 제어 확인 | CHHapticEngine.capabilities | Vibrator.hasAmplitudeControl |

## 요구사항

- iOS 16.0+
- Android SDK 26+
- Flutter 3.10+

## 라이선스

MIT License

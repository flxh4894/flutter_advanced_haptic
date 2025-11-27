import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_advanced_haptic/flutter_advanced_haptic.dart';

void main() {
  group('HapticPreset', () {
    test('should have correct default intensities', () {
      expect(HapticPreset.light.defaultIntensity, 0.3);
      expect(HapticPreset.medium.defaultIntensity, 0.5);
      expect(HapticPreset.heavy.defaultIntensity, 0.8);
      expect(HapticPreset.short.defaultIntensity, 0.5);
      expect(HapticPreset.long.defaultIntensity, 0.5);
      expect(HapticPreset.success.defaultIntensity, 0.6);
      expect(HapticPreset.warning.defaultIntensity, 0.7);
      expect(HapticPreset.error.defaultIntensity, 0.9);
    });

    test('should have correct default durations', () {
      expect(HapticPreset.light.defaultDuration, 10);
      expect(HapticPreset.medium.defaultDuration, 20);
      expect(HapticPreset.heavy.defaultDuration, 30);
      expect(HapticPreset.short.defaultDuration, 50);
      expect(HapticPreset.long.defaultDuration, 200);
      expect(HapticPreset.success.defaultDuration, 40);
      expect(HapticPreset.warning.defaultDuration, 60);
      expect(HapticPreset.error.defaultDuration, 80);
    });
  });

  group('HapticEvent', () {
    test('should create vibrate event correctly', () {
      final event = HapticEvent.vibrate(duration: 100, intensity: 0.7);
      expect(event.duration, 100);
      expect(event.intensity, 0.7);
      expect(event.isPause, false);
    });

    test('should create pause event correctly', () {
      final event = HapticEvent.pause(50);
      expect(event.duration, 50);
      expect(event.intensity, 0.0);
      expect(event.isPause, true);
    });

    test('should convert to map correctly', () {
      final event = HapticEvent(duration: 100, intensity: 0.5);
      final map = event.toMap();
      expect(map['duration'], 100);
      expect(map['intensity'], 0.5);
    });

    test('should create from map correctly', () {
      final map = {'duration': 100, 'intensity': 0.5};
      final event = HapticEvent.fromMap(map);
      expect(event.duration, 100);
      expect(event.intensity, 0.5);
    });
  });

  group('HapticPattern', () {
    test('should create single pattern correctly', () {
      final pattern = HapticPattern.single(duration: 100, intensity: 0.5);
      expect(pattern.events.length, 1);
      expect(pattern.events[0].duration, 100);
      expect(pattern.events[0].intensity, 0.5);
    });

    test('should create double tap pattern correctly', () {
      final pattern = HapticPattern.doubleTap();
      expect(pattern.events.length, 3);
      expect(pattern.events[0].isPause, false);
      expect(pattern.events[1].isPause, true);
      expect(pattern.events[2].isPause, false);
    });

    test('should create triple tap pattern correctly', () {
      final pattern = HapticPattern.tripleTap();
      expect(pattern.events.length, 5);
    });

    test('should create heartbeat pattern correctly', () {
      final pattern = HapticPattern.heartbeat();
      expect(pattern.events.length, 4);
    });

    test('should calculate total duration correctly', () {
      final pattern = HapticPattern([
        HapticEvent.vibrate(duration: 50, intensity: 0.5),
        HapticEvent.pause(30),
        HapticEvent.vibrate(duration: 50, intensity: 0.5),
      ]);
      expect(pattern.totalDuration, 130);
    });

    test('should create custom pattern correctly', () {
      final pattern = HapticPattern.custom(
        pattern: [100, 50, 200],
        intensities: [0.3, 0.9],
      );
      expect(pattern.events.length, 3);
      expect(pattern.events[0].intensity, 0.3);
      expect(pattern.events[1].intensity, 0.0); // pause
      expect(pattern.events[2].intensity, 0.9);
    });

    test('should convert to map list correctly', () {
      final pattern = HapticPattern([
        HapticEvent.vibrate(duration: 50, intensity: 0.5),
        HapticEvent.pause(30),
      ]);
      final mapList = pattern.toMapList();
      expect(mapList.length, 2);
      expect(mapList[0]['duration'], 50);
      expect(mapList[0]['intensity'], 0.5);
      expect(mapList[1]['duration'], 30);
      expect(mapList[1]['intensity'], 0.0);
    });
  });

  group('HapticWebViewBridge', () {
    test('should have default channel name', () {
      final bridge = HapticWebViewBridge();
      expect(bridge.channelName, 'FlutterHapticBridge');
    });

    test('should allow custom channel name', () {
      final bridge = HapticWebViewBridge(channelName: 'CustomBridge');
      expect(bridge.channelName, 'CustomBridge');
    });

    test('should generate injection script', () {
      final bridge = HapticWebViewBridge();
      final script = bridge.getInjectionScript();
      expect(script.contains('FlutterHaptic'), true);
      expect(script.contains('FlutterHapticBridge'), true);
      expect(script.contains('postMessage'), true);
    });
  });
}

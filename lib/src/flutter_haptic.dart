import 'package:flutter/services.dart';

import 'haptic_pattern.dart';
import 'haptic_preset.dart';

/// Main class for haptic feedback functionality.
class FlutterHaptic {
  FlutterHaptic._();

  static const MethodChannel _channel =
      MethodChannel('flutter_advanced_haptic');

  /// Singleton instance.
  static final FlutterHaptic instance = FlutterHaptic._();

  /// Triggers a preset haptic feedback.
  ///
  /// [preset] - The type of haptic feedback to trigger.
  Future<void> preset(HapticPreset preset) async {
    await _channel.invokeMethod('preset', {
      'type': preset.name,
      'intensity': preset.defaultIntensity,
      'duration': preset.defaultDuration,
    });
  }

  /// Triggers a custom haptic feedback with specified intensity and duration.
  ///
  /// [intensity] - Vibration strength from 0.0 (none) to 1.0 (maximum).
  /// [duration] - Duration in milliseconds.
  Future<void> vibrate({
    double intensity = 0.5,
    int duration = 50,
  }) async {
    assert(intensity >= 0.0 && intensity <= 1.0, 'Intensity must be 0.0-1.0');
    assert(duration > 0, 'Duration must be positive');

    await _channel.invokeMethod('vibrate', {
      'intensity': intensity,
      'duration': duration,
    });
  }

  /// Plays a haptic pattern (sequence of vibrations and pauses).
  ///
  /// [pattern] - The haptic pattern to play.
  Future<void> playPattern(HapticPattern pattern) async {
    await _channel.invokeMethod('playPattern', {
      'events': pattern.toMapList(),
    });
  }

  /// Cancels any ongoing haptic feedback.
  Future<void> cancel() async {
    await _channel.invokeMethod('cancel');
  }

  /// Checks if haptic feedback is supported on this device.
  Future<bool> isSupported() async {
    final result = await _channel.invokeMethod<bool>('isSupported');
    return result ?? false;
  }

  /// Checks if custom intensity control is supported.
  ///
  /// Some older devices may only support on/off vibration.
  Future<bool> supportsIntensity() async {
    final result = await _channel.invokeMethod<bool>('supportsIntensity');
    return result ?? false;
  }

  // Convenience methods for common presets

  /// Light haptic feedback.
  Future<void> light() => preset(HapticPreset.light);

  /// Medium haptic feedback.
  Future<void> medium() => preset(HapticPreset.medium);

  /// Heavy haptic feedback.
  Future<void> heavy() => preset(HapticPreset.heavy);

  /// Short vibration.
  Future<void> short() => preset(HapticPreset.short);

  /// Long vibration.
  Future<void> long() => preset(HapticPreset.long);

  /// Success feedback.
  Future<void> success() => preset(HapticPreset.success);

  /// Warning feedback.
  Future<void> warning() => preset(HapticPreset.warning);

  /// Error feedback.
  Future<void> error() => preset(HapticPreset.error);
}

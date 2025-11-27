/// Predefined haptic feedback presets.
enum HapticPreset {
  /// Light haptic feedback - subtle tap sensation.
  light,

  /// Medium haptic feedback - moderate tap sensation.
  medium,

  /// Heavy haptic feedback - strong tap sensation.
  heavy,

  /// Short vibration - quick burst.
  short,

  /// Long vibration - extended duration.
  long,

  /// Success feedback - positive confirmation.
  success,

  /// Warning feedback - cautionary alert.
  warning,

  /// Error feedback - negative/failure indication.
  error,
}

/// Extension to provide default configurations for presets.
extension HapticPresetConfig on HapticPreset {
  /// Default intensity for this preset (0.0 to 1.0).
  double get defaultIntensity {
    switch (this) {
      case HapticPreset.light:
        return 0.3;
      case HapticPreset.medium:
        return 0.5;
      case HapticPreset.heavy:
        return 0.8;
      case HapticPreset.short:
        return 0.5;
      case HapticPreset.long:
        return 0.5;
      case HapticPreset.success:
        return 0.6;
      case HapticPreset.warning:
        return 0.7;
      case HapticPreset.error:
        return 0.9;
    }
  }

  /// Default duration in milliseconds for this preset.
  int get defaultDuration {
    switch (this) {
      case HapticPreset.light:
        return 10;
      case HapticPreset.medium:
        return 20;
      case HapticPreset.heavy:
        return 30;
      case HapticPreset.short:
        return 50;
      case HapticPreset.long:
        return 200;
      case HapticPreset.success:
        return 40;
      case HapticPreset.warning:
        return 60;
      case HapticPreset.error:
        return 80;
    }
  }
}

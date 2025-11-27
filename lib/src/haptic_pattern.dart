/// Represents a single haptic event in a pattern.
class HapticEvent {
  /// Creates a haptic event.
  const HapticEvent({
    required this.duration,
    this.intensity = 0.5,
  })  : assert(duration >= 0, 'Duration must be non-negative'),
        assert(
            intensity >= 0.0 && intensity <= 1.0, 'Intensity must be 0.0-1.0');

  /// Duration in milliseconds.
  final int duration;

  /// Intensity from 0.0 to 1.0.
  final double intensity;

  /// Creates a vibration event.
  factory HapticEvent.vibrate({
    required int duration,
    double intensity = 0.5,
  }) {
    return HapticEvent(duration: duration, intensity: intensity);
  }

  /// Creates a pause (no vibration) event.
  factory HapticEvent.pause(int duration) {
    return HapticEvent(duration: duration, intensity: 0.0);
  }

  /// Whether this is a pause (no vibration).
  bool get isPause => intensity == 0.0;

  /// Converts to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'duration': duration,
      'intensity': intensity,
    };
  }

  /// Creates from a map.
  factory HapticEvent.fromMap(Map<String, dynamic> map) {
    return HapticEvent(
      duration: map['duration'] as int,
      intensity: (map['intensity'] as num).toDouble(),
    );
  }
}

/// Represents a sequence of haptic events forming a pattern.
class HapticPattern {
  /// Creates a haptic pattern from a list of events.
  const HapticPattern(this.events);

  /// The sequence of haptic events.
  final List<HapticEvent> events;

  /// Creates a simple single vibration pattern.
  factory HapticPattern.single({
    required int duration,
    double intensity = 0.5,
  }) {
    return HapticPattern([
      HapticEvent.vibrate(duration: duration, intensity: intensity),
    ]);
  }

  /// Creates a double tap pattern.
  factory HapticPattern.doubleTap({
    int duration = 30,
    int pause = 50,
    double intensity = 0.5,
  }) {
    return HapticPattern([
      HapticEvent.vibrate(duration: duration, intensity: intensity),
      HapticEvent.pause(pause),
      HapticEvent.vibrate(duration: duration, intensity: intensity),
    ]);
  }

  /// Creates a triple tap pattern.
  factory HapticPattern.tripleTap({
    int duration = 30,
    int pause = 50,
    double intensity = 0.5,
  }) {
    return HapticPattern([
      HapticEvent.vibrate(duration: duration, intensity: intensity),
      HapticEvent.pause(pause),
      HapticEvent.vibrate(duration: duration, intensity: intensity),
      HapticEvent.pause(pause),
      HapticEvent.vibrate(duration: duration, intensity: intensity),
    ]);
  }

  /// Creates a heartbeat pattern.
  factory HapticPattern.heartbeat({double intensity = 0.6}) {
    return HapticPattern([
      HapticEvent.vibrate(duration: 50, intensity: intensity),
      HapticEvent.pause(100),
      HapticEvent.vibrate(duration: 100, intensity: intensity * 0.8),
      HapticEvent.pause(300),
    ]);
  }

  /// Creates a custom pattern from duration/intensity pairs.
  ///
  /// [pattern] is a list of alternating vibrate and pause durations.
  /// [intensities] optionally specifies intensity for each vibration.
  factory HapticPattern.custom({
    required List<int> pattern,
    List<double>? intensities,
    double defaultIntensity = 0.5,
  }) {
    final events = <HapticEvent>[];
    int intensityIndex = 0;

    for (int i = 0; i < pattern.length; i++) {
      final isVibrate = i % 2 == 0;
      if (isVibrate) {
        final intensity =
            intensities != null && intensityIndex < intensities.length
                ? intensities[intensityIndex++]
                : defaultIntensity;
        events.add(HapticEvent.vibrate(
          duration: pattern[i],
          intensity: intensity,
        ));
      } else {
        events.add(HapticEvent.pause(pattern[i]));
      }
    }

    return HapticPattern(events);
  }

  /// Total duration of the pattern in milliseconds.
  int get totalDuration {
    return events.fold(0, (sum, event) => sum + event.duration);
  }

  /// Converts to a list of maps for platform channel communication.
  List<Map<String, dynamic>> toMapList() {
    return events.map((e) => e.toMap()).toList();
  }

  /// Creates from a list of maps.
  factory HapticPattern.fromMapList(List<dynamic> list) {
    return HapticPattern(
      list
          .map((e) => HapticEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

import 'dart:convert';

import 'flutter_haptic.dart';
import 'haptic_pattern.dart';
import 'haptic_preset.dart';

/// Callback type for handling messages from webview.
typedef WebViewMessageHandler = void Function(String message);

/// Bridge for WebView haptic communication via JavaScript Channel.
///
/// This class provides methods to:
/// 1. Generate JavaScript code to inject into WebView
/// 2. Handle incoming messages from WebView
///
/// Usage with webview_flutter:
/// ```dart
/// final bridge = HapticWebViewBridge();
///
/// WebView(
///   javascriptChannels: {
///     JavascriptChannel(
///       name: bridge.channelName,
///       onMessageReceived: (message) {
///         bridge.handleMessage(message.message);
///       },
///     ),
///   },
///   onWebViewCreated: (controller) async {
///     await controller.runJavascript(bridge.getInjectionScript());
///   },
/// )
/// ```
///
/// In your web content, call haptic methods like:
/// ```javascript
/// // Using preset
/// FlutterHaptic.preset('medium');
///
/// // Using custom vibration
/// FlutterHaptic.vibrate({ intensity: 0.7, duration: 100 });
///
/// // Using pattern
/// FlutterHaptic.pattern([
///   { duration: 50, intensity: 0.5 },
///   { duration: 30, intensity: 0 },  // pause
///   { duration: 50, intensity: 0.5 },
/// ]);
///
/// // Cancel ongoing haptic
/// FlutterHaptic.cancel();
/// ```
class HapticWebViewBridge {
  /// Creates a haptic webview bridge.
  ///
  /// [channelName] - The JavaScript channel name (default: 'FlutterHapticBridge').
  /// [haptic] - The FlutterHaptic instance to use (default: singleton).
  HapticWebViewBridge({
    this.channelName = 'FlutterHapticBridge',
    FlutterHaptic? haptic,
  }) : _haptic = haptic ?? FlutterHaptic.instance;

  /// The JavaScript channel name for postMessage communication.
  final String channelName;

  final FlutterHaptic _haptic;

  /// Generates the JavaScript code to inject into WebView.
  ///
  /// This creates a global `FlutterHaptic` object with methods:
  /// - `preset(type)` - Trigger a preset haptic
  /// - `vibrate({intensity, duration})` - Custom vibration
  /// - `pattern(events)` - Play a pattern
  /// - `cancel()` - Cancel ongoing haptic
  /// - `isSupported()` - Check if haptic is supported
  String getInjectionScript() {
    return '''
(function() {
  if (window.FlutterHaptic) return;

  const channelName = '$channelName';

  function postMessage(data) {
    if (window[channelName] && window[channelName].postMessage) {
      window[channelName].postMessage(JSON.stringify(data));
    } else {
      console.warn('FlutterHaptic: Bridge channel not available');
    }
  }

  window.FlutterHaptic = {
    preset: function(type) {
      postMessage({
        method: 'preset',
        type: type
      });
    },

    vibrate: function(options) {
      options = options || {};
      postMessage({
        method: 'vibrate',
        intensity: options.intensity !== undefined ? options.intensity : 0.5,
        duration: options.duration !== undefined ? options.duration : 50
      });
    },

    pattern: function(events) {
      postMessage({
        method: 'pattern',
        events: events
      });
    },

    cancel: function() {
      postMessage({
        method: 'cancel'
      });
    },

    isSupported: function() {
      return true;
    },

    // Convenience methods
    light: function() { this.preset('light'); },
    medium: function() { this.preset('medium'); },
    heavy: function() { this.preset('heavy'); },
    short: function() { this.preset('short'); },
    long: function() { this.preset('long'); },
    success: function() { this.preset('success'); },
    warning: function() { this.preset('warning'); },
    error: function() { this.preset('error'); }
  };

  console.log('FlutterHaptic: Bridge initialized');
})();
''';
  }

  /// Handles a message received from WebView.
  ///
  /// Call this method when receiving a message on the JavaScript channel.
  Future<void> handleMessage(String message) async {
    try {
      final data = json.decode(message) as Map<String, dynamic>;
      final method = data['method'] as String?;

      switch (method) {
        case 'preset':
          await _handlePreset(data);
          break;
        case 'vibrate':
          await _handleVibrate(data);
          break;
        case 'pattern':
          await _handlePattern(data);
          break;
        case 'cancel':
          await _haptic.cancel();
          break;
        default:
          // Unknown method, ignore
          break;
      }
    } catch (e) {
      // Silently ignore malformed messages
    }
  }

  Future<void> _handlePreset(Map<String, dynamic> data) async {
    final type = data['type'] as String?;
    if (type == null) return;

    final preset = _parsePreset(type);
    if (preset != null) {
      await _haptic.preset(preset);
    }
  }

  Future<void> _handleVibrate(Map<String, dynamic> data) async {
    final intensity = (data['intensity'] as num?)?.toDouble() ?? 0.5;
    final duration = (data['duration'] as num?)?.toInt() ?? 50;

    await _haptic.vibrate(
      intensity: intensity.clamp(0.0, 1.0),
      duration: duration.clamp(1, 10000),
    );
  }

  Future<void> _handlePattern(Map<String, dynamic> data) async {
    final events = data['events'] as List?;
    if (events == null || events.isEmpty) return;

    final hapticEvents = events.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return HapticEvent(
        duration: (map['duration'] as num?)?.toInt() ?? 50,
        intensity: (map['intensity'] as num?)?.toDouble() ?? 0.5,
      );
    }).toList();

    await _haptic.playPattern(HapticPattern(hapticEvents));
  }

  HapticPreset? _parsePreset(String type) {
    switch (type.toLowerCase()) {
      case 'light':
        return HapticPreset.light;
      case 'medium':
        return HapticPreset.medium;
      case 'heavy':
        return HapticPreset.heavy;
      case 'short':
        return HapticPreset.short;
      case 'long':
        return HapticPreset.long;
      case 'success':
        return HapticPreset.success;
      case 'warning':
        return HapticPreset.warning;
      case 'error':
        return HapticPreset.error;
      default:
        return null;
    }
  }
}

import Flutter
import UIKit
import CoreHaptics

public class FlutterHapticPlugin: NSObject, FlutterPlugin {
    private var hapticEngine: CHHapticEngine?
    private var currentPlayer: CHHapticPatternPlayer?
    private let feedbackGenerator = UIImpactFeedbackGenerator()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_advanced_haptic", binaryMessenger: registrar.messenger())
        let instance = FlutterHapticPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    override init() {
        super.init()
        setupHapticEngine()
    }

    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.isAutoShutdownEnabled = true
            hapticEngine?.resetHandler = { [weak self] in
                self?.restartEngine()
            }
            hapticEngine?.stoppedHandler = { [weak self] reason in
                self?.restartEngine()
            }
            try hapticEngine?.start()
        } catch {
            print("FlutterHaptic: Failed to create haptic engine: \(error)")
        }
    }

    private func restartEngine() {
        do {
            try hapticEngine?.start()
        } catch {
            print("FlutterHaptic: Failed to restart haptic engine: \(error)")
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "preset":
            handlePreset(call, result: result)
        case "vibrate":
            handleVibrate(call, result: result)
        case "playPattern":
            handlePlayPattern(call, result: result)
        case "cancel":
            handleCancel(result: result)
        case "isSupported":
            result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
        case "supportsIntensity":
            result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handlePreset(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let type = args["type"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        let intensity = args["intensity"] as? Double ?? 0.5
        let duration = args["duration"] as? Int ?? 50

        switch type {
        case "light":
            playImpactFeedback(style: .light)
        case "medium":
            playImpactFeedback(style: .medium)
        case "heavy":
            playImpactFeedback(style: .heavy)
        case "success":
            playNotificationFeedback(type: .success)
        case "warning":
            playNotificationFeedback(type: .warning)
        case "error":
            playNotificationFeedback(type: .error)
        case "short", "long":
            playCustomHaptic(intensity: intensity, duration: Double(duration) / 1000.0)
        default:
            playCustomHaptic(intensity: intensity, duration: Double(duration) / 1000.0)
        }

        result(nil)
    }

    private func handleVibrate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        let intensity = args["intensity"] as? Double ?? 0.5
        let duration = args["duration"] as? Int ?? 50

        playCustomHaptic(intensity: intensity, duration: Double(duration) / 1000.0)
        result(nil)
    }

    private func handlePlayPattern(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let events = args["events"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        playPatternHaptic(events: events)
        result(nil)
    }

    private func handleCancel(result: @escaping FlutterResult) {
        do {
            try currentPlayer?.stop(atTime: CHHapticTimeImmediate)
            currentPlayer = nil
        } catch {
            print("FlutterHaptic: Failed to stop haptic: \(error)")
        }
        result(nil)
    }

    private func playImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    private func playNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    private func playCustomHaptic(intensity: Double, duration: Double) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = hapticEngine else {
            // Fallback to basic haptic
            playImpactFeedback(style: intensity > 0.6 ? .heavy : (intensity > 0.3 ? .medium : .light))
            return
        }

        do {
            try engine.start()

            let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
            let hapticSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(intensity * 0.5))

            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [hapticIntensity, hapticSharpness],
                relativeTime: 0,
                duration: duration
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)

            currentPlayer = player
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("FlutterHaptic: Failed to play custom haptic: \(error)")
            // Fallback
            playImpactFeedback(style: .medium)
        }
    }

    private func playPatternHaptic(events: [[String: Any]]) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = hapticEngine else {
            // Fallback: play first non-pause event as impact
            if let firstEvent = events.first(where: { ($0["intensity"] as? Double ?? 0) > 0 }) {
                let intensity = firstEvent["intensity"] as? Double ?? 0.5
                playImpactFeedback(style: intensity > 0.6 ? .heavy : (intensity > 0.3 ? .medium : .light))
            }
            return
        }

        do {
            try engine.start()

            var hapticEvents: [CHHapticEvent] = []
            var currentTime: Double = 0

            for event in events {
                let duration = Double(event["duration"] as? Int ?? 50) / 1000.0
                let intensity = event["intensity"] as? Double ?? 0.5

                if intensity > 0 {
                    let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
                    let hapticSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(intensity * 0.5))

                    let hapticEvent = CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [hapticIntensity, hapticSharpness],
                        relativeTime: currentTime,
                        duration: duration
                    )
                    hapticEvents.append(hapticEvent)
                }

                currentTime += duration
            }

            if hapticEvents.isEmpty { return }

            let pattern = try CHHapticPattern(events: hapticEvents, parameters: [])
            let player = try engine.makePlayer(with: pattern)

            currentPlayer = player
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("FlutterHaptic: Failed to play pattern haptic: \(error)")
        }
    }
}

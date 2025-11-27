package dev.polymorph.flutter_advanced_haptic

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.HapticFeedbackConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

class FlutterHapticPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var vibrator: Vibrator? = null
    private var currentJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_advanced_haptic")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "preset" -> handlePreset(call, result)
            "vibrate" -> handleVibrate(call, result)
            "playPattern" -> handlePlayPattern(call, result)
            "cancel" -> handleCancel(result)
            "isSupported" -> result.success(vibrator?.hasVibrator() == true)
            "supportsIntensity" -> result.success(hasAmplitudeControl())
            else -> result.notImplemented()
        }
    }

    private fun handlePreset(call: MethodCall, result: Result) {
        val type = call.argument<String>("type") ?: run {
            result.error("INVALID_ARGS", "Type is required", null)
            return
        }
        val intensity = call.argument<Double>("intensity") ?: 0.5
        val duration = call.argument<Int>("duration") ?: 50

        when (type) {
            "light" -> vibrate(intensity = 0.3, duration = 10)
            "medium" -> vibrate(intensity = 0.5, duration = 20)
            "heavy" -> vibrate(intensity = 0.8, duration = 30)
            "short" -> vibrate(intensity = intensity, duration = 50)
            "long" -> vibrate(intensity = intensity, duration = 200)
            "success" -> playSuccessPattern()
            "warning" -> playWarningPattern()
            "error" -> playErrorPattern()
            else -> vibrate(intensity = intensity, duration = duration)
        }

        result.success(null)
    }

    private fun handleVibrate(call: MethodCall, result: Result) {
        val intensity = call.argument<Double>("intensity") ?: 0.5
        val duration = call.argument<Int>("duration") ?: 50

        vibrate(intensity = intensity, duration = duration)
        result.success(null)
    }

    private fun handlePlayPattern(call: MethodCall, result: Result) {
        val events = call.argument<List<Map<String, Any>>>("events") ?: run {
            result.error("INVALID_ARGS", "Events are required", null)
            return
        }

        playPattern(events)
        result.success(null)
    }

    private fun handleCancel(result: Result) {
        currentJob?.cancel()
        vibrator?.cancel()
        result.success(null)
    }

    private fun vibrate(intensity: Double, duration: Int) {
        val vib = vibrator ?: return

        val amplitude = (intensity * 255).toInt().coerceIn(1, 255)

        if (hasAmplitudeControl()) {
            val effect = VibrationEffect.createOneShot(duration.toLong(), amplitude)
            vib.vibrate(effect)
        } else {
            @Suppress("DEPRECATION")
            vib.vibrate(duration.toLong())
        }
    }

    private fun playPattern(events: List<Map<String, Any>>) {
        val vib = vibrator ?: return

        // Cancel any ongoing pattern
        currentJob?.cancel()
        vib.cancel()

        // Build timing and amplitude arrays
        val timings = mutableListOf<Long>()
        val amplitudes = mutableListOf<Int>()

        for (event in events) {
            val duration = (event["duration"] as? Number)?.toLong() ?: 50L
            val intensity = (event["intensity"] as? Number)?.toDouble() ?: 0.5
            val amplitude = if (intensity > 0) {
                (intensity * 255).toInt().coerceIn(1, 255)
            } else {
                0
            }

            timings.add(duration)
            amplitudes.add(amplitude)
        }

        if (timings.isEmpty()) return

        if (hasAmplitudeControl()) {
            val effect = VibrationEffect.createWaveform(
                timings.toLongArray(),
                amplitudes.toIntArray(),
                -1 // Don't repeat
            )
            vib.vibrate(effect)
        } else {
            // Fallback: use coroutine for pattern playback without amplitude control
            currentJob = scope.launch {
                for (i in timings.indices) {
                    if (amplitudes[i] > 0) {
                        @Suppress("DEPRECATION")
                        vib.vibrate(timings[i])
                        delay(timings[i])
                    } else {
                        delay(timings[i])
                    }
                }
            }
        }
    }

    private fun playSuccessPattern() {
        playPattern(listOf(
            mapOf("duration" to 40, "intensity" to 0.4),
            mapOf("duration" to 60, "intensity" to 0.0),
            mapOf("duration" to 60, "intensity" to 0.6)
        ))
    }

    private fun playWarningPattern() {
        playPattern(listOf(
            mapOf("duration" to 50, "intensity" to 0.7),
            mapOf("duration" to 50, "intensity" to 0.0),
            mapOf("duration" to 50, "intensity" to 0.7)
        ))
    }

    private fun playErrorPattern() {
        playPattern(listOf(
            mapOf("duration" to 80, "intensity" to 0.9),
            mapOf("duration" to 40, "intensity" to 0.0),
            mapOf("duration" to 80, "intensity" to 0.9),
            mapOf("duration" to 40, "intensity" to 0.0),
            mapOf("duration" to 80, "intensity" to 0.9)
        ))
    }

    private fun hasAmplitudeControl(): Boolean {
        return vibrator?.hasAmplitudeControl() == true
    }
}

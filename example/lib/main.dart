import 'package:flutter/material.dart';
import 'package:flutter_advanced_haptic/flutter_advanced_haptic.dart';

import 'webview_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Haptic Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HapticExamplePage(),
    );
  }
}

class HapticExamplePage extends StatefulWidget {
  const HapticExamplePage({super.key});

  @override
  State<HapticExamplePage> createState() => _HapticExamplePageState();
}

class _HapticExamplePageState extends State<HapticExamplePage> {
  final _haptic = FlutterHaptic.instance;
  bool _isSupported = false;
  bool _supportsIntensity = false;
  double _customIntensity = 0.5;
  int _customDuration = 100;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final isSupported = await _haptic.isSupported();
    final supportsIntensity = await _haptic.supportsIntensity();
    setState(() {
      _isSupported = isSupported;
      _supportsIntensity = supportsIntensity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Haptic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSupportInfo(),
            const SizedBox(height: 24),
            _buildPresetSection(),
            const SizedBox(height: 24),
            _buildCustomSection(),
            const SizedBox(height: 24),
            _buildPatternSection(),
            const SizedBox(height: 24),
            _buildWebViewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Haptic supported: ${_isSupported ? "Yes" : "No"}'),
            Text('Intensity control: ${_supportsIntensity ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _presetButton('Light', _haptic.light),
                _presetButton('Medium', _haptic.medium),
                _presetButton('Heavy', _haptic.heavy),
                _presetButton('Short', _haptic.short),
                _presetButton('Long', _haptic.long),
                _presetButton('Success', _haptic.success),
                _presetButton('Warning', _haptic.warning),
                _presetButton('Error', _haptic.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetButton(String label, Future<void> Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildCustomSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Vibration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Intensity: ${_customIntensity.toStringAsFixed(2)}'),
            Slider(
              value: _customIntensity,
              min: 0.0,
              max: 1.0,
              onChanged: (value) => setState(() => _customIntensity = value),
            ),
            Text('Duration: ${_customDuration}ms'),
            Slider(
              value: _customDuration.toDouble(),
              min: 10,
              max: 500,
              divisions: 49,
              onChanged: (value) =>
                  setState(() => _customDuration = value.round()),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _haptic.vibrate(
                intensity: _customIntensity,
                duration: _customDuration,
              ),
              child: const Text('Vibrate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patterns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _haptic.playPattern(
                    HapticPattern.doubleTap(),
                  ),
                  child: const Text('Double Tap'),
                ),
                ElevatedButton(
                  onPressed: () => _haptic.playPattern(
                    HapticPattern.tripleTap(),
                  ),
                  child: const Text('Triple Tap'),
                ),
                ElevatedButton(
                  onPressed: () => _haptic.playPattern(
                    HapticPattern.heartbeat(),
                  ),
                  child: const Text('Heartbeat'),
                ),
                ElevatedButton(
                  onPressed: () => _haptic.playPattern(
                    HapticPattern.custom(
                      pattern: [100, 50, 200, 100, 50],
                      intensities: [0.3, 0.6, 0.9],
                    ),
                  ),
                  child: const Text('Custom'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _haptic.cancel(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WebView Bridge',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test haptic feedback from within a WebView using JavaScript bridge.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WebViewExamplePage(),
                  ),
                );
              },
              child: const Text('Open WebView Example'),
            ),
          ],
        ),
      ),
    );
  }
}

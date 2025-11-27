import 'package:flutter/material.dart';
import 'package:flutter_advanced_haptic/flutter_advanced_haptic.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExamplePage extends StatefulWidget {
  const WebViewExamplePage({super.key});

  @override
  State<WebViewExamplePage> createState() => _WebViewExamplePageState();
}

class _WebViewExamplePageState extends State<WebViewExamplePage> {
  late final WebViewController _controller;
  final HapticWebViewBridge _bridge = HapticWebViewBridge();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
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
            // Inject the haptic bridge script
            await _controller.runJavaScript(_bridge.getInjectionScript());
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_getHtmlContent());
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      margin: 0;
      padding: 16px;
      background: #f5f5f5;
    }
    h1 { font-size: 20px; color: #333; margin-bottom: 16px; }
    h2 { font-size: 16px; color: #666; margin: 16px 0 8px; }
    .card {
      background: white;
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 16px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .button-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 8px;
    }
    button {
      padding: 12px 16px;
      border: none;
      border-radius: 8px;
      background: #6366f1;
      color: white;
      font-size: 14px;
      font-weight: 500;
      cursor: pointer;
      transition: transform 0.1s, background 0.2s;
    }
    button:active {
      transform: scale(0.98);
      background: #4f46e5;
    }
    button.secondary {
      background: #e5e7eb;
      color: #374151;
    }
    button.secondary:active {
      background: #d1d5db;
    }
    button.danger {
      background: #ef4444;
    }
    button.danger:active {
      background: #dc2626;
    }
    .slider-container {
      margin: 12px 0;
    }
    label {
      display: block;
      margin-bottom: 4px;
      color: #666;
      font-size: 14px;
    }
    input[type="range"] {
      width: 100%;
    }
    .value {
      text-align: right;
      font-size: 12px;
      color: #999;
    }
    .code {
      background: #1f2937;
      color: #10b981;
      padding: 12px;
      border-radius: 8px;
      font-family: monospace;
      font-size: 12px;
      overflow-x: auto;
      white-space: pre;
    }
  </style>
</head>
<body>
  <h1>WebView Haptic Bridge</h1>

  <div class="card">
    <h2>Presets</h2>
    <div class="button-grid">
      <button onclick="FlutterHaptic.light()">Light</button>
      <button onclick="FlutterHaptic.medium()">Medium</button>
      <button onclick="FlutterHaptic.heavy()">Heavy</button>
      <button onclick="FlutterHaptic.short()">Short</button>
      <button onclick="FlutterHaptic.long()">Long</button>
      <button onclick="FlutterHaptic.success()">Success</button>
      <button onclick="FlutterHaptic.warning()">Warning</button>
      <button onclick="FlutterHaptic.error()">Error</button>
    </div>
  </div>

  <div class="card">
    <h2>Custom Vibration</h2>
    <div class="slider-container">
      <label>Intensity: <span id="intensityValue">0.5</span></label>
      <input type="range" id="intensity" min="0" max="100" value="50"
        oninput="document.getElementById('intensityValue').textContent = (this.value/100).toFixed(2)">
    </div>
    <div class="slider-container">
      <label>Duration: <span id="durationValue">100</span>ms</label>
      <input type="range" id="duration" min="10" max="500" value="100"
        oninput="document.getElementById('durationValue').textContent = this.value">
    </div>
    <button onclick="customVibrate()" style="width:100%">Vibrate</button>
  </div>

  <div class="card">
    <h2>Pattern</h2>
    <div class="button-grid">
      <button class="secondary" onclick="doubleTap()">Double Tap</button>
      <button class="secondary" onclick="tripleTap()">Triple Tap</button>
      <button class="secondary" onclick="heartbeat()">Heartbeat</button>
      <button class="secondary" onclick="sosPattern()">SOS</button>
    </div>
    <button class="danger" onclick="FlutterHaptic.cancel()" style="width:100%; margin-top:8px">Cancel</button>
  </div>

  <div class="card">
    <h2>Usage Example</h2>
    <div class="code">// Preset
FlutterHaptic.medium();

// Custom vibration
FlutterHaptic.vibrate({
  intensity: 0.7,
  duration: 100
});

// Pattern
FlutterHaptic.pattern([
  {duration: 50, intensity: 0.5},
  {duration: 30, intensity: 0},
  {duration: 50, intensity: 0.5}
]);</div>
  </div>

  <script>
    function customVibrate() {
      var intensity = document.getElementById('intensity').value / 100;
      var duration = parseInt(document.getElementById('duration').value);
      FlutterHaptic.vibrate({ intensity: intensity, duration: duration });
    }

    function doubleTap() {
      FlutterHaptic.pattern([
        { duration: 30, intensity: 0.5 },
        { duration: 50, intensity: 0 },
        { duration: 30, intensity: 0.5 }
      ]);
    }

    function tripleTap() {
      FlutterHaptic.pattern([
        { duration: 30, intensity: 0.5 },
        { duration: 50, intensity: 0 },
        { duration: 30, intensity: 0.5 },
        { duration: 50, intensity: 0 },
        { duration: 30, intensity: 0.5 }
      ]);
    }

    function heartbeat() {
      FlutterHaptic.pattern([
        { duration: 50, intensity: 0.6 },
        { duration: 100, intensity: 0 },
        { duration: 100, intensity: 0.5 },
        { duration: 300, intensity: 0 }
      ]);
    }

    function sosPattern() {
      // S = ...  O = ---  S = ...
      FlutterHaptic.pattern([
        // S
        { duration: 50, intensity: 0.5 },
        { duration: 50, intensity: 0 },
        { duration: 50, intensity: 0.5 },
        { duration: 50, intensity: 0 },
        { duration: 50, intensity: 0.5 },
        { duration: 150, intensity: 0 },
        // O
        { duration: 150, intensity: 0.7 },
        { duration: 50, intensity: 0 },
        { duration: 150, intensity: 0.7 },
        { duration: 50, intensity: 0 },
        { duration: 150, intensity: 0.7 },
        { duration: 150, intensity: 0 },
        // S
        { duration: 50, intensity: 0.5 },
        { duration: 50, intensity: 0 },
        { duration: 50, intensity: 0.5 },
        { duration: 50, intensity: 0 },
        { duration: 50, intensity: 0.5 }
      ]);
    }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Bridge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

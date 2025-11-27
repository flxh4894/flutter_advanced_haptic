Pod::Spec.new do |s|
  s.name             = 'flutter_advanced_haptic'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin for advanced haptic feedback.'
  s.description      = <<-DESC
A Flutter plugin for advanced haptic feedback with customizable intensity, duration, and WebView bridge support.
                       DESC
  s.homepage         = 'https://github.com/flxh4894/flutter_advanced_haptic'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Polymorph' => 'dev@polymorph.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '16.0'
  s.swift_version    = '5.0'
end

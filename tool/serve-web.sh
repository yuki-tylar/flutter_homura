echo '===== homura initializer for web ====='
dart 'tool/rewrite_homura_config.dart'
echo 'flutter run -d chrome --web-port=64550'
flutter run -d chrome --web-port=64550
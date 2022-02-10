echo '===== homura initializer ====='
dart tools/services/check_firebase_options_exists.dart
[ $? -eq 2 ] && exit

dart tools/services/check_homura_config_exists.dart
[ $? -eq 2 ] && exit

dart tools/services/init_configure.dart
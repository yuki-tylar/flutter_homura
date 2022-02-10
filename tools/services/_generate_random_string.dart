import 'dart:math';

generateRandomString({
  int length = 3,
  bool uppercase = false,
  bool lowercase = false,
  bool number = false,
  List<String> excludes = const [],
}) {
  String _u = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String _l = _u.toLowerCase();
  String _n = '0123456789';

  String _s = '';
  if (uppercase) {
    _s += _u;
  }
  if (lowercase) {
    _s += _l;
  }
  if (number) {
    _s += _n;
  }

  Random _rnd = Random();

  bool duplicated = excludes.isNotEmpty;
  String result = '';
  Map<String, bool> excludesMap = {
    for (var e in excludes) e: true,
  };

  do {
    result = String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _s.codeUnitAt(_rnd.nextInt(_s.length)),
      ),
    );

    duplicated = excludesMap.containsKey(result);
  } while (duplicated);
  return result;
}

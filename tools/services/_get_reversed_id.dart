String getReversedId(String id) {
  var ids = id.split('.');
  var reversed = '';
  for (var _id in ids) {
    reversed = _id + '.' + reversed;
  }

  return reversed.substring(0, reversed.length - 1);
}

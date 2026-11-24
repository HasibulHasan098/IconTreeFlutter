import 'dart:collection';
import 'dart:convert';

/// Parses `#rgb` or `#rrggbb` into a Lottie `[r, g, b, a]` list (channels 0..1, alpha always 1).
List<double> hexToRgba(String hex) {
  var h = hex.startsWith('#') ? hex.substring(1) : hex;
  if (h.length == 3) h = '${h[0]}${h[0]}${h[1]}${h[1]}${h[2]}${h[2]}';
  double channel(int start) {
    if (start >= h.length) return 0;
    final end = start + 2 > h.length ? h.length : start + 2;
    return (int.tryParse(h.substring(start, end), radix: 16) ?? 0) / 255;
  }

  return [channel(0), channel(2), channel(4), 1];
}

void _recolorLayer(Map<String, dynamic> layer, List<double> color) {
  final layers = layer['layers'];
  if (layers is List) {
    for (final sub in layers) {
      if (sub is Map<String, dynamic>) _recolorLayer(sub, color);
    }
  }
  final shapes = layer['shapes'];
  if (shapes is List) {
    for (final shape in shapes) {
      if (shape is Map<String, dynamic>) _recolorShape(shape, color);
    }
  }
}

void _recolorShape(Map<String, dynamic> shape, List<double> color) {
  final ty = shape['ty'];
  if (ty == 'fl' || ty == 'st') {
    final c = shape['c'];
    if (c is Map<String, dynamic> && c['k'] != null) c['k'] = List<double>.of(color);
  }
  final items = shape['it'];
  if (items is List) {
    for (final child in items) {
      if (child is Map<String, dynamic>) _recolorShape(child, color);
    }
  }
}

/// Returns a recolored deep copy of Lottie animation data: every solid fill (`fl`) and stroke
/// (`st`) color is replaced with [color] (a hex string such as `"#ff0000"`). [json] is not modified.
Map<String, dynamic> recolorLottie(Map<String, dynamic> json, String color) {
  final clone = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
  final rgba = hexToRgba(color);
  final layers = clone['layers'];
  if (layers is List) {
    for (final layer in layers) {
      if (layer is Map<String, dynamic>) _recolorLayer(layer, rgba);
    }
  }
  return clone;
}

const int _memoLimit = 64;
final LinkedHashMap<String, Map<String, dynamic>> _memo = LinkedHashMap();

/// Like [recolorLottie] but memoized (LRU, 64 entries) by icon ID and color.
Map<String, dynamic> getRecoloredLottie(String iconId, Map<String, dynamic> json, String color) {
  final key = '$iconId-$color';
  final cached = _memo.remove(key);
  if (cached != null) {
    _memo[key] = cached;
    return cached;
  }
  final result = recolorLottie(json, color);
  _memo[key] = result;
  if (_memo.length > _memoLimit) _memo.remove(_memo.keys.first);
  return result;
}

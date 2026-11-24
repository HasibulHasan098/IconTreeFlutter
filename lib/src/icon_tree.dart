import 'icon_ids.dart';

/// Icon identifiers are plain strings such as `"heart"`; see [iconIds] for the full list.
typedef IconId = String;

/// Local icon index and search. Nothing here touches the network.
class IconTree {
  IconTree._();

  /// Package name, needed to resolve the bundled asset paths.
  static const String packageName = 'icon_tree_animate';

  /// All bundled icon IDs.
  static List<IconId> get ids => iconIds;

  /// Returns icon IDs containing any query term (case-insensitive). Commas and whitespace both
  /// separate terms, matching `npx icontree search`.
  static List<IconId> search(String query) {
    final terms = query.trim().toLowerCase().split(RegExp(r'[\s,]+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return const [];
    return iconIds.where((id) {
      final normalized = id.toLowerCase();
      return terms.any(normalized.contains);
    }).toList();
  }

  /// Asset path of the Lottie JSON for [id].
  static String assetPath(IconId id) => 'assets/icons/$id.json';
}

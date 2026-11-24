import 'package:flutter/material.dart';
import 'package:icon_tree_animate/icon_tree_animate.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Gallery()));

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  String query = '';
  IconMode mode = IconMode.static;
  Color? color;
  double size = 40;
  int clicks = 0;
  final trigger = IconTrigger();

  static const palette = <String, Color?>{
    'Current': null,
    'Red': Color(0xFFE5484D),
    'Blue': Color(0xFF2477D4),
    'Green': Color(0xFF30A46C),
  };

  @override
  Widget build(BuildContext context) {
    final ids = query.trim().isEmpty ? iconIds : IconTree.search(query);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            Text('icon_tree_animate · ${iconIds.length} icons', style: const TextStyle(fontSize: 18)),
            TextField(
              decoration: const InputDecoration(labelText: 'Search (e.g. "arrow right" or "heart,star")'),
              onChanged: (v) => setState(() => query = v),
            ),
            Wrap(spacing: 6, children: [
              for (final m in IconMode.values)
                ChoiceChip(label: Text(m.name), selected: mode == m, onSelected: (_) => setState(() => mode = m)),
            ]),
            Wrap(spacing: 6, children: [
              for (final e in palette.entries)
                ChoiceChip(label: Text(e.key), selected: color == e.value, onSelected: (_) => setState(() => color = e.value)),
            ]),
            Slider(value: size, min: 16, max: 96, onChanged: (v) => setState(() => size = v)),
            Row(children: [
              FilledButton(onPressed: trigger.play, child: const Text('Like')),
              const SizedBox(width: 12),
              TreeIcon(id: 'heart', size: 32, color: const Color(0xFFE5484D), mode: IconMode.onClick, trigger: trigger, onTap: () => setState(() => clicks++)),
              const SizedBox(width: 12),
              Text('triggered $clicks×'),
            ]),
            Text('${ids.length} results'),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 100, mainAxisExtent: 100),
                itemCount: ids.length,
                itemBuilder: (_, i) => Column(children: [
                  TreeIcon(id: ids[i], size: size, color: color, mode: mode),
                  Text(ids[i], style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

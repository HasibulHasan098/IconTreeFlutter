import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icon_tree_animate/icon_tree_animate.dart';
import 'package:icon_tree_animate/src/recolor.dart' show hexToRgba;

Map<String, dynamic> sample() => {
      'layers': [
        {
          'ty': 4,
          'shapes': [
            {
              'ty': 'gr',
              'it': [
                {'ty': 'fl', 'c': {'k': [0, 0, 0, 1]}},
                {'ty': 'st', 'c': {'k': [1, 1, 1, 1]}},
                {'ty': 'sh'},
              ],
            },
          ],
        },
        {
          'ty': 0,
          'layers': [
            {
              'ty': 4,
              'shapes': [
                {'ty': 'fl', 'c': {'k': [0.5, 0.5, 0.5, 1]}},
              ],
            },
          ],
        },
      ],
    };

void main() {
  group('recolor', () {
    test('recolors nested fills and strokes', () {
      final out = recolorLottie(sample(), '#ff0000');
      final group = out['layers'][0]['shapes'][0]['it'];
      expect(group[0]['c']['k'], [1.0, 0.0, 0.0, 1.0]);
      expect(group[1]['c']['k'], [1.0, 0.0, 0.0, 1.0]);
      expect(out['layers'][1]['layers'][0]['shapes'][0]['c']['k'], [1.0, 0.0, 0.0, 1.0]);
    });

    test('does not mutate input', () {
      final input = sample();
      final before = jsonEncode(input);
      recolorLottie(input, '#00ff00');
      expect(jsonEncode(input), before);
    });

    test('expands short hex', () {
      expect(hexToRgba('#f0f'), [1.0, 0.0, 1.0, 1.0]);
    });

    test('memoizes by icon and color', () {
      final input = sample();
      final a = getRecoloredLottie('memo', input, '#123456');
      expect(identical(a, getRecoloredLottie('memo', input, '#123456')), isTrue);
      expect(identical(a, getRecoloredLottie('memo', input, '#654321')), isFalse);
    });
  });

  group('registry', () {
    final dir = Directory('assets/icons');
    final onDisk = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    test('matches icon folder', () {
      expect(onDisk.length, 946);
      final names = onDisk.map((f) => f.uri.pathSegments.last.replaceAll(RegExp(r'(\.json)+$'), '')).toSet();
      expect(names, iconIds.toSet());
      expect(iconIds.toSet().length, iconIds.length);
    });

    test('every icon is valid Lottie', () {
      for (final f in onDisk) {
        final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        expect(json.containsKey('layers'), isTrue, reason: f.path);
      }
    });

    test('search matches any term like the CLI', () {
      expect(IconTree.search('arrow right'), contains('arrow-right'));
      expect(IconTree.search('heart,star'), containsAll(['heart', 'star']));
      expect(IconTree.search('zzzz-no-such-icon'), isEmpty);
      expect(IconTree.search('  '), isEmpty);
      expect(IconTree.search('HEART'), contains('heart'));
    });
  });

  testWidgets('TreeIcon renders and fires onTap in onClick mode', (tester) async {
    var taps = 0;
    final trigger = IconTrigger();
    await tester.pumpWidget(MaterialApp(
      home: Column(children: [
        TreeIcon(id: 'heart', mode: IconMode.onClick, onTap: () => taps++, trigger: trigger),
        const TreeIcon(id: 'no-such-icon'),
      ]),
    ));
    await tester.pump();
    await tester.tap(find.byType(TreeIcon).first);
    expect(taps, 1);
    trigger.play();
    expect(taps, 2);
  });
}

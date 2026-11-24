<h1 align="center">IconTree for Flutter</h1>

<p align="center">
  <b>946 animated icons for Flutter. Recolorable, searchable, fully offline.</b><br/>
  One widget. No network, no API keys, no icon fonts.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white">
  <img alt="Platforms" src="https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey">
  <img alt="Icons" src="https://img.shields.io/badge/icons-946-orange">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="Offline" src="https://img.shields.io/badge/network-none-success">
</p>

```dart
TreeIcon(id: 'heart', size: 24, color: Color(0xFFE5484D), mode: IconMode.onClick)
```

`IconTree for Flutter` is the Flutter sibling of the [`icon-tree-animate`](https://www.npmjs.com/package/icon-tree-animate) npm package and [IconTreeKotlin](https://github.com/HasibulHasan098/IconTreeKotlin). It has the same icon set, the same recolor functions, the same search and the same four playback modes, so web, Android and Flutter apps can share one icon vocabulary.

## Why IconTree

| | |
|---|---|
| **Animated by default** | 946 Lottie icons, with static, loop, click and hover playback built in. No extra animation code. |
| **100% offline** | Every icon ships inside the package's assets. Nothing is downloaded at runtime, so there's no loading spinner, no CDN outage and no privacy question. |
| **One codebase, every platform** | Works on Android, iOS, web and desktop. Built on the well-maintained [`lottie`](https://pub.dev/packages/lottie) package. |
| **Recolor at runtime** | Tint any icon with one `Color`. Every solid fill and stroke follows it. |
| **Follows your theme** | By default the icon takes `IconTheme`'s color, so it matches buttons, app bars and dark mode automatically. |
| **Same API as the other packages** | `TreeIcon`, `IconMode`, `recolorLottie`, `getRecoloredLottie`, `IconId` and search all exist across npm, Kotlin and Flutter. |
| **Searchable** | `IconTree.search('arrow right')` finds icons by name locally, with the same matching rules as `npx icontree search`. |
| **Tested** | Unit and widget tests check the recolor logic, search behavior, and that the registry matches the icon files on disk and every file is valid Lottie. |

## Install

```yaml
# pubspec.yaml
dependencies:
  icon_tree_animate:
    git:
      url: https://github.com/HasibulHasan098/IconTreeFlutter.git
      ref: 1.0.0
```

Then run `flutter pub get`. Requires Flutter 3.24 or newer.

## Quick start

```dart
import 'package:icon_tree_animate/icon_tree_animate.dart';

ElevatedButton.icon(
  onPressed: save,
  icon: const TreeIcon(id: 'heart', size: 24, color: Color(0xFFE5484D), mode: IconMode.onClick),
  label: const Text('Save'),
);
```

### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `id` | `String` | required | Icon name, such as `'heart'` or `'arrow-right'` |
| `size` | `double` | `24` | Width and height |
| `color` | `Color?` | `null` | Tint. `null` follows `IconTheme` (the equivalent of `currentColor`) |
| `mode` | `IconMode` | `static` | `static`, `loop`, `onClick` or `hover` |
| `onTap` | `VoidCallback?` | `null` | Callback for click playback |
| `trigger` | `IconTrigger?` | `null` | Start playback from another widget (the equivalent of `bindId`) |
| `resetAfterPlay` | `bool` | `true` | Return to frame zero when a one-shot finishes |

### Playback modes

- `static` shows the first frame.
- `loop` plays continuously.
- `onClick` plays once on tap and calls `onTap`.
- `hover` plays once when a pointer enters the icon (mouse, stylus, web, desktop).

### Trigger an icon from another widget

```dart
final trigger = IconTrigger();

FilledButton(onPressed: trigger.play, child: const Text('Like'));
TreeIcon(id: 'heart', mode: IconMode.onClick, trigger: trigger, onTap: like);
```

## Find an icon

```dart
IconTree.search('arrow right');  // IDs containing "arrow" or "right"
IconTree.search('heart,star');   // commas and spaces both separate terms
iconIds;                         // every bundled ID
```

Search runs against the bundled index. It makes no network requests.

## Recoloring

```dart
final tinted = recolorLottie(json, '#2477d4');               // returns a recolored copy
final cached = getRecoloredLottie('heart', json, '#2477d4'); // memoized (LRU)
```

These match the other packages: solid fills and strokes are replaced, and the input is never mutated. The `TreeIcon` widget itself recolors through Lottie value delegates, so the animation is parsed once and a color change is cheap.

## Example app

`example/` is a gallery with search, mode and color switchers, size control and an external trigger demo.

```bash
cd example && flutter run
```

## Development

```bash
flutter test                          # unit and widget tests
node scripts/generate-registry.js     # after adding or removing files in assets/icons/
```

## Performance notes

- Looping many icons at once is real drawing work. Prefer `static`, `onClick` or `hover` in large grids, and test performance in a profile or release build.
- The package bundles all 946 icons (about 12 MB of JSON, compressed in the app bundle).

## License

The package code is released under the [MIT License](LICENSE).

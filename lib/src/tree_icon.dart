import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import 'icon_tree.dart';

/// Playback behavior, matching the npm and Kotlin packages' `mode`.
enum IconMode {
  /// Displays the first frame.
  static,

  /// Plays continuously.
  loop,

  /// Plays once when tapped (also calls `onTap`).
  onClick,

  /// Plays once when a pointer enters the icon (mouse, stylus, desktop, web).
  hover,
}

/// Starts an [IconMode.onClick] icon from some other widget (the equivalent of `bindId`).
/// Create one, pass it to [TreeIcon], and call [play] (e.g. from a button's `onPressed`).
class IconTrigger extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void play() {
    _count++;
    notifyListeners();
  }
}

/// An animated icon from the bundled set.
class TreeIcon extends StatefulWidget {
  const TreeIcon({
    super.key,
    required this.id,
    this.size = 24,
    this.color,
    this.mode = IconMode.static,
    this.onTap,
    this.trigger,
    this.resetAfterPlay = true,
  });

  /// Icon name, such as `"heart"` or `"arrow-right"` (see `iconIds` and `IconTree.search`).
  final IconId id;

  /// Width and height.
  final double size;

  /// Tint for all solid fills and strokes. `null` means "current color": it follows
  /// `IconTheme` (the equivalent of `currentColor`).
  final Color? color;

  final IconMode mode;

  /// Callback for [IconMode.onClick] playback.
  final VoidCallback? onTap;

  /// External trigger for [IconMode.onClick] playback (npm `bindId`).
  final IconTrigger? trigger;

  /// Return to the first frame when a one-shot playback completes.
  final bool resetAfterPlay;

  @override
  State<TreeIcon> createState() => _TreeIconState();
}

class _TreeIconState extends State<TreeIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.trigger?.addListener(_onTrigger);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.mode != IconMode.loop && widget.resetAfterPlay) {
        _controller.value = 0;
      }
    });
  }

  @override
  void didUpdateWidget(TreeIcon old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) {
      old.trigger?.removeListener(_onTrigger);
      widget.trigger?.addListener(_onTrigger);
    }
    if (old.mode != widget.mode || old.id != widget.id) {
      if (old.id != widget.id) _loaded = false;
      _applyMode();
    }
  }

  @override
  void dispose() {
    widget.trigger?.removeListener(_onTrigger);
    _controller.dispose();
    super.dispose();
  }

  void _applyMode() {
    if (!_loaded) return;
    if (widget.mode == IconMode.loop) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  void _playOnce() {
    if (_loaded) _controller.forward(from: 0);
  }

  void _onTrigger() {
    if (widget.mode != IconMode.onClick) return;
    _playOnce();
    widget.onTap?.call();
  }

  void _onTap() {
    if (widget.mode != IconMode.onClick) return;
    _playOnce();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    final lottieColor = color.withAlpha(0xFF);

    Widget child = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        IconTree.assetPath(widget.id),
        package: IconTree.packageName,
        controller: _controller,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          _loaded = true;
          _applyMode();
        },
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        delegates: LottieDelegates(values: [
          ValueDelegate.color(const ['**'], value: lottieColor),
          ValueDelegate.strokeColor(const ['**'], value: lottieColor),
        ]),
      ),
    );

    if (widget.mode == IconMode.hover) {
      child = MouseRegion(onEnter: (_) => _playOnce(), child: child);
    }
    if (widget.mode == IconMode.onClick) {
      child = GestureDetector(behavior: HitTestBehavior.opaque, onTap: _onTap, child: child);
    }
    return child;
  }
}

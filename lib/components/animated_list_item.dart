import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.alreadyAnimated = false,
    this.onAnimated,
    this.duration = const Duration(milliseconds: 350),
    this.delayPerItem = 40,
    this.slideOffset = const Offset(0, 0.08),
  });

  final int index;
  final Widget child;
  final bool alreadyAnimated;
  final VoidCallback? onAnimated;

  final Duration duration;
  final int delayPerItem;
  final Offset slideOffset;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> {
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = widget.alreadyAnimated;
    if (widget.alreadyAnimated) return;
    final delay = Duration(milliseconds: widget.index * widget.delayPerItem);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(delay, () {
        if (!mounted) return;
        setState(() => _visible = true);
        Future.delayed(widget.duration, () {
          widget.onAnimated?.call();
        });
      });
    });
  }

  @override
  void didUpdateWidget(AnimatedListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alreadyAnimated && !_visible) {
      _visible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : widget.slideOffset,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

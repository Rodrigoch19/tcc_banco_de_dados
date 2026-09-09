import 'package:flutter/material.dart';

/// Compartilha o ciclo de animacao e respeita a preferencia de movimento reduzido.
class LoopAnimation extends StatefulWidget {
  const LoopAnimation({
    super.key,
    required this.builder,
    required this.duration,
    this.reverse = false,
    this.enabled = true,
    this.child,
  });

  final Widget Function(BuildContext context, double progress, Widget? child)
      builder;
  final Duration duration;
  final bool reverse;
  final bool enabled;
  final Widget? child;

  @override
  State<LoopAnimation> createState() => _LoopAnimationState();
}

class _LoopAnimationState extends State<LoopAnimation>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(LoopAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration ||
        oldWidget.reverse != widget.reverse ||
        oldWidget.enabled != widget.enabled) {
      _controller.duration = widget.duration;
      _controller.stop();
      _sync();
    }
  }

  void _sync() {
    if (widget.enabled && !MediaQuery.disableAnimationsOf(context)) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: widget.reverse);
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) =>
            widget.builder(context, _controller.value, child),
      );
}

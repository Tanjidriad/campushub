import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Scales down slightly while pressed; optional light haptic.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.hapticOnTap = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool hapticOnTap;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.hapticOnTap) {
                HapticFeedback.lightImpact();
              }
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

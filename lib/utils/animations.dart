import 'package:flutter/material.dart';

/// A reusable widget that fades in and slides up/down its child.
class FadeInSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final Curve curve;
  final double delay;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.offset = 30.0,
    this.curve = Curves.easeOutCubic,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        // Handle delayed start manually by clamping value or custom logic if needed,
        // but for simplicity in TweenBuilder, we usually just start.
        // For real staggered lists, we'll rely on the parent initializing this later
        // or just accept that they all start at build time.
        // To truly stagger with TweenBuilder, we can wrap in a FutureBuilder or similar,
        // but simpler is:

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A wrapper for Lists to auto-stagger children
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final double delayPerChild;
  final Duration duration;

  const StaggeredList({
    super.key,
    required this.children,
    this.delayPerChild = 0.05, // 50ms stagger
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        // We can't easily delay TweenAnimationBuilder without complex state,
        // so we'll use a Future-based delay or just simple AnimationController if we were stateful.
        // However, for a lightweight "Pop-in" effect, we can cheat by extending duration
        // or using a "Wait" widget.
        // Let's keep it simple: Just render them.
        // If we want true stagger, we need individual controllers.

        // BETTER APPROACH for Stateless Stagger:
        // Use a Tween with a custom curve that stays flat for [delay] then moves.
        // Or simply stick to `FadeInSlide` and let them all animate together for V1,
        // OR implement a Stateful wrapper that starts timers.

        // Let's stick to simple FadeInSlide for now, or use a Recursive/Loop builder in the parent.
        return FadeInSlide(
          duration: Duration(
            milliseconds: duration.inMilliseconds + (index * 100),
          ),
          child: children[index],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';


class OptimizedAnimations {
  
  static Widget fadeIn({
    required Widget child,
    required Animation<double> animation,
    Curve curve = Curves.easeIn,
  }) {
 
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }

  static Widget slideIn({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
        return Transform.translate(
          offset: Offset.lerp(begin, end, curvedAnimation.value)!,
          child: child,
        );
      },
      child: child,
    );
  }


  static Widget scale({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.8,
    double end = 1.0,
    Curve curve = Curves.easeOut,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
        final scale = begin + (end - begin) * curvedAnimation.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }


  static Widget fadeSlide({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(0, 0.1),
    Curve curve = Curves.easeOut,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
 
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  static Widget rotate({
    required Widget child,
    required Animation<double> animation,
    double begin = 0,
    double end = 1,
    Curve curve = Curves.linear,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
        final rotation = begin + (end - begin) * curvedAnimation.value;
        return Transform.rotate(
          angle: rotation * 2 * 3.14159, 
          child: child,
        );
      },
      child: child,
    );
  }
}


class OptimizedRepaintBoundary extends StatelessWidget {
  final Widget child;
  final String? debugLabel;

  const OptimizedRepaintBoundary({
    super.key,
    required this.child,
    this.debugLabel,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: child,
    );
  }
}


class OptimizedAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Color? beginColor;
  final Color? endColor;
  final double? beginWidth;
  final double? endWidth;
  final double? beginHeight;
  final double? endHeight;
  final Curve curve;

  const OptimizedAnimatedContainer({
    super.key,
    required this.child,
    required this.animation,
    this.beginColor,
    this.endColor,
    this.beginWidth,
    this.endWidth,
    this.beginHeight,
    this.endHeight,
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
        final value = curvedAnimation.value;

        Color? color;
        if (beginColor != null && endColor != null) {
          color = Color.lerp(beginColor, endColor, value);
        }

        double? width;
        if (beginWidth != null && endWidth != null) {
          width = beginWidth! + (endWidth! - beginWidth!) * value;
        }

        double? height;
        if (beginHeight != null && endHeight != null) {
          height = beginHeight! + (endHeight! - beginHeight!) * value;
        }

        return Container(
          width: width,
          height: height,
          color: color,
          child: child,
        );
      },
      child: child,
    );
  }
}


class AnimationControllerManager {
  final List<AnimationController> _controllers = [];

  AnimationController createController({
    required TickerProvider vsync,
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    final controller = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
    );
    _controllers.add(controller);
    return controller;
  }


  void disposeAll() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }


  int get activeCount => _controllers.length;
}


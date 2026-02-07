import 'package:flutter/material.dart';

/// Optimized Animation Helper
/// Provides reusable, performance-optimized animation patterns
/// Uses AnimatedBuilder and RepaintBoundary for better performance
class OptimizedAnimations {
  /// Fade in animation with optimized builder
  /// Uses FadeTransition instead of Opacity for better GPU performance
  static Widget fadeIn({
    required Widget child,
    required Animation<double> animation,
    Curve curve = Curves.easeIn,
  }) {
    // Use FadeTransition - applies opacity using GPU's fragment shader (faster)
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }

  /// Slide in animation with optimized builder
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

  /// Scale animation with optimized builder
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

  /// Combined fade and slide animation
  /// Uses FadeTransition and SlideTransition for GPU-accelerated performance
  static Widget fadeSlide({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(0, 0.1),
    Curve curve = Curves.easeOut,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
    // Use built-in transitions for GPU fragment shader optimization
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  /// Rotation animation with optimized builder
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
          angle: rotation * 2 * 3.14159, // Convert to radians
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Repaint Boundary Wrapper
/// Isolates expensive widgets from unnecessary repaints
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

/// Optimized Animated Container
/// Uses Transform instead of changing widget properties for better performance
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

/// Animation Controller Manager
/// Helps manage multiple animation controllers and ensures proper disposal
class AnimationControllerManager {
  final List<AnimationController> _controllers = [];

  /// Create and register an animation controller
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

  /// Dispose all registered controllers
  void disposeAll() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }

  /// Get count of active controllers
  int get activeCount => _controllers.length;
}

/// Example usage:
/// 
/// class MyAnimatedWidget extends StatefulWidget {
///   @override
///   _MyAnimatedWidgetState createState() => _MyAnimatedWidgetState();
/// }
/// 
/// class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
///     with SingleTickerProviderStateMixin {
///   late AnimationController _controller;
///   late Animation<double> _animation;
/// 
///   @override
///   void initState() {
///     super.initState();
///     _controller = AnimationController(
///       duration: const Duration(milliseconds: 300),
///       vsync: this,
///     );
///     _animation = CurvedAnimation(
///       parent: _controller,
///       curve: Curves.easeInOut,
///     );
///     _controller.forward();
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return OptimizedRepaintBoundary(
///       child: OptimizedAnimations.fadeSlide(
///         animation: _animation,
///         child: const ExpensiveWidget(),
///       ),
///     );
///   }
/// 
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
/// }

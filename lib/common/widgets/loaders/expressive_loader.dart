import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpressiveLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final bool isContained;
  final String? semanticLabel;

  const ExpressiveLoader({
    super.key,
    this.size = 48,
    this.color,
    this.isContained = false,
    this.semanticLabel,
  });


  static double responsiveSize(BuildContext context, {double baseSize = 48}) {
    final double width = MediaQuery.of(context).size.width;
 
    if (width > 1200) return (baseSize * 2.5).clamp(24.0, 240.0);
    if (width > 600) return (baseSize * 1.5).clamp(24.0, 240.0);
    return baseSize.clamp(24.0, 240.0);
  }

  @override
  State<ExpressiveLoader> createState() => _ExpressiveLoaderState();
}

class _ExpressiveLoaderState extends State<ExpressiveLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _morphAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loaderColor = widget.color ?? 
        (widget.isContained ? colorScheme.onPrimaryContainer : colorScheme.primary);
    
    final double targetSize = widget.size.clamp(24.0, 240.0);
    final double activeShapeBaseSize = (targetSize / 48) * 38;

    return Semantics(
      label: widget.semanticLabel ?? 'Loading...',
      role: SemanticsRole.progressBar,
      container: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Container(
              width: targetSize,
              height: targetSize,
              decoration: widget.isContained ? BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(targetSize / 4),
              ) : null,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Center(
                  child: CustomPaint(
                    size: Size(activeShapeBaseSize, activeShapeBaseSize),
                    painter: _M3ExpressivePainter(
                      color: loaderColor,
                      progress: _morphAnimation.value,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _M3ExpressivePainter extends CustomPainter {
  final Color color;
  final double progress;

  _M3ExpressivePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final rect = Offset.zero & size;
    final double t = progress * 7; 
    final int index = t.floor();
    final double subProgress = t - index;

    final List<BorderRadius> shapes = [
      BorderRadius.circular(size.width / 2), // Circle
      BorderRadius.all(Radius.circular(size.width / 3.5)), // Squircle
      BorderRadius.only(topLeft: Radius.circular(size.width / 2), bottomRight: Radius.circular(size.width / 2), topRight: const Radius.circular(8), bottomLeft: const Radius.circular(8)), // Morph 1
      BorderRadius.all(Radius.circular(size.width / 4)), // Rounded Rect
      BorderRadius.only(topRight: Radius.circular(size.width / 2), bottomLeft: Radius.circular(size.width / 2), topLeft: const Radius.circular(8), bottomRight: const Radius.circular(8)), // Morph 2
      BorderRadius.all(Radius.circular(size.width / 5)), // Tighter Squircle
      BorderRadius.circular(size.width / 2), // Back to Circle
    ];

    final BorderRadius current = shapes[index % 7];
    final BorderRadius next = shapes[(index + 1) % 7];
    final BorderRadius? lerped = BorderRadius.lerp(current, next, subProgress);

    if (lerped != null) {
      canvas.drawRRect(lerped.toRRect(rect), paint);
    }
  }

  @override
  bool shouldRepaint(_M3ExpressivePainter oldDelegate) => oldDelegate.progress != progress;
}

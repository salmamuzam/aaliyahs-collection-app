import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpressiveLinearProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final bool isThick;
  final bool isWavy;
  final String? semanticLabel;

  const ExpressiveLinearProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.isThick = true,
    this.isWavy = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double height = isThick ? 8.0 : 4.0;

    final Color activeColor = color ?? colorScheme.primary;
    final Color trackColor = backgroundColor ?? colorScheme.secondaryContainer;
    final TextDirection textDirection = Directionality.of(context);

    return Semantics(
      label: semanticLabel ?? 'Loading progress',
      value: value != null ? '${(value! * 100).toInt()}%' : null,
      role: SemanticsRole.progressBar,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: height + (isWavy ? 8 : 0),
          constraints: const BoxConstraints(minWidth: 80),
          child: CustomPaint(
            painter: _ExpressiveLinearPainter(
              value: value,
              activeColor: activeColor,
              trackColor: trackColor,
              isWavy: isWavy,
              height: height,
              textDirection: textDirection,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpressiveLinearPainter extends CustomPainter {
  final double? value;
  final Color activeColor;
  final Color trackColor;
  final bool isWavy;
  final double height;
  final TextDirection textDirection;

  _ExpressiveLinearPainter({
    required this.value,
    required this.activeColor,
    required this.trackColor,
    required this.isWavy,
    required this.height,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;
    
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;


    if (textDirection == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final RRect trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (size.height - height) / 2, size.width, height),
      Radius.circular(height / 2),
    );


    canvas.drawRRect(trackRRect, trackPaint);

    if (value == null) {
 
      final double indeterminateWidth = size.width * 0.3;
      final RRect activeRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, (size.height - height) / 2, indeterminateWidth, height),
        Radius.circular(height / 2),
      );
      canvas.drawRRect(activeRRect, activePaint);
      return;
    }


    final double minDotWidth = height; 
    final double calculatedWidth = value! * size.width;
    final double activeWidth = calculatedWidth < minDotWidth ? minDotWidth : calculatedWidth;
    
    final double startY = size.height / 2;

    if (isWavy) {
      final path = Path();

      const double amplitude = 4.0;
      const double wavelength = 24.0;
      
      path.moveTo(0, startY);
      for (double x = 0; x <= activeWidth; x++) {
        final double y = startY + amplitude * math.sin(x / wavelength * 2 * math.pi);
        path.lineTo(x, y);
      }
      
      final wavyPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = height
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, wavyPaint);
      
 
      canvas.drawCircle(
        Offset(activeWidth, startY + amplitude * math.sin(activeWidth / wavelength * 2 * math.pi)), 
        2.0, 
        activePaint
      );
    } else {
      final RRect activeRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, (size.height - height) / 2, activeWidth, height),
        Radius.circular(height / 2),
      );
      canvas.drawRRect(activeRRect, activePaint);
      

      canvas.drawCircle(Offset(activeWidth, startY), 2.0, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveLinearPainter oldDelegate) => 
      oldDelegate.value != value || 
      oldDelegate.isWavy != isWavy || 
      oldDelegate.textDirection != textDirection;
}


class ExpressiveCircularProgressIndicator extends StatefulWidget {
  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final double size;
  final bool isWavy;
  final bool showTrack;
  final String? semanticLabel;

  const ExpressiveCircularProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 8.0, 
    this.size = 48.0,
    this.isWavy = false,
    this.showTrack = true,
    this.semanticLabel,
  });

  @override
  State<ExpressiveCircularProgressIndicator> createState() => _ExpressiveCircularProgressIndicatorState();
}

class _ExpressiveCircularProgressIndicatorState extends State<ExpressiveCircularProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(ExpressiveCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color activeColor = widget.color ?? colorScheme.primary;
    final Color trackColor = widget.backgroundColor ?? colorScheme.secondaryContainer;

    return Semantics(
      label: widget.semanticLabel ?? 'Loading progress',
      value: widget.value != null ? '${(widget.value! * 100).toInt()}%' : null,
      role: SemanticsRole.progressBar,
      container: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _ExpressiveCircularPainter(
                value: widget.value,
                activeColor: activeColor,
                trackColor: trackColor,
                strokeWidth: widget.strokeWidth,
                isWavy: widget.isWavy,
                showTrack: widget.showTrack,
                animationValue: _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExpressiveCircularPainter extends CustomPainter {
  final double? value;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;
  final bool isWavy;
  final bool showTrack;
  final double animationValue;

  _ExpressiveCircularPainter({
    required this.value,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
    required this.isWavy,
    required this.showTrack,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (showTrack) {
      final trackPaint = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, trackPaint);
    }

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (value != null) {
 
      final double minSweep = (strokeWidth / (2 * math.pi * radius)) * 2 * math.pi;
      double sweepAngle = 2 * math.pi * value!;
      if (sweepAngle < minSweep && value! > 0) sweepAngle = minSweep;

      if (isWavy) {
        _paintWavyArc(canvas, center, radius, -math.pi / 2, sweepAngle, activePaint);
      } else {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, activePaint);
      }
    } else {

      final startAngle = animationValue * 2 * math.pi;
      const double sweepAngle = math.pi * 1.5;
      if (isWavy) {
        _paintWavyArc(canvas, center, radius, startAngle, sweepAngle, activePaint);
      } else {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, activePaint);
      }
    }
  }

  void _paintWavyArc(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Paint paint) {
    final path = Path();
    const int segments = 100;
    final double angleStep = sweepAngle / segments;
    
   
    final double amplitude = strokeWidth / 4;

    const double frequency = 12.0;

    for (int i = 0; i <= segments; i++) {
      final currentAngle = startAngle + i * angleStep;
      final currentRadius = radius + amplitude * math.sin(i * angleStep * frequency);
      final x = center.dx + currentRadius * math.cos(currentAngle);
      final y = center.dy + currentRadius * math.sin(currentAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ExpressiveCircularPainter oldDelegate) => true;
}


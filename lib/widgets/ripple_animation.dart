import 'package:flutter/material.dart';
import 'dart:math' as math;

// Add the Ripple effect widget
class RippleAnimation extends StatefulWidget {
  final Widget child;
  final Color? rippleColor;
  final Duration duration;

  const RippleAnimation({
    Key? key,
    required this.child,
    this.rippleColor,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  RippleAnimationState createState() => RippleAnimationState();
}

class RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRippling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRippling = false;
        });
        _controller.reset();
      }
    });
  }

  void startRipple() {
    // Always reset the controller to ensure it starts from the beginning
    _controller.reset();

    // Set rippling state to true
    setState(() {
      _isRippling = true;
    });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (_isRippling)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.all(
                        5), // Create some padding to reduce visible area
                    child: CustomPaint(
                      painter: RipplePainter(
                        color: widget.rippleColor ??
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                        animationValue: _animation.value,
                      ),
                    ),
                  ),
                ),
              ),
            widget.child,
          ],
        );
      },
    );
  }
}

// Custom painter for the ripple effect
class RipplePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  RipplePainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double maxRippleSize =
        math.sqrt(size.width * size.width + size.height * size.height) * 0.5;
    final double rippleSize = maxRippleSize * animationValue;

    final Paint paint = Paint()
      ..color = color.withOpacity(1 - animationValue * 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(rect.center, rippleSize, paint);
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.animationValue != animationValue;
  }
}

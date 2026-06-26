import 'package:flutter/material.dart';
import 'dart:math' as math;

class CaritaWidget extends StatelessWidget {
  final double size;
  final Color color;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final int expressionType;

  const CaritaWidget({
    super.key,
    required this.size,
    required this.color,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.expressionType = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Widget carita = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
          center: const Alignment(-0.3, -0.3),
        ),
      ),
      child: CustomPaint(
        painter: FacePainter(expressionType: expressionType),
      ),
    );

    if (top != null || left != null || right != null || bottom != null) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: carita,
      );
    }

    return carita;
  }
}

class FacePainter extends CustomPainter {
  final int expressionType;

  FacePainter({required this.expressionType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    final eyePaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.5, size.height * 0.5);

    switch (expressionType) {
      case 0:
        canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), size.width * 0.05, eyePaint);
        canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), size.width * 0.05, eyePaint);
        final smilePath = Path()
          ..moveTo(size.width * 0.3, size.height * 0.6)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.8, size.width * 0.7, size.height * 0.6);
        canvas.drawPath(smilePath, paint);
        break;

      case 1:
        final eyePath = Path()
          ..moveTo(size.width * 0.25, size.height * 0.45)
          ..quadraticBezierTo(size.width * 0.35, size.height * 0.35, size.width * 0.45, size.height * 0.45);
        canvas.drawPath(eyePath, paint);
        canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), size.width * 0.05, eyePaint);
        final smilePath2 = Path()
          ..moveTo(size.width * 0.35, size.height * 0.65)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.75, size.width * 0.65, size.height * 0.65);
        canvas.drawPath(smilePath2, paint);
        break;

      case 2:
        canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), size.width * 0.06, eyePaint);
        canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), size.width * 0.06, eyePaint);
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), size.width * 0.08, paint);
        break;

      case 3:
        canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), size.width * 0.05, eyePaint);
        canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), size.width * 0.05, eyePaint);
        final smirkPath = Path()
          ..moveTo(size.width * 0.3, size.height * 0.65)
          ..quadraticBezierTo(size.width * 0.6, size.height * 0.75, size.width * 0.7, size.height * 0.6);
        canvas.drawPath(smirkPath, paint);
        break;

      case 4:
        final eyeL = Path()
          ..moveTo(size.width * 0.25, size.height * 0.45)
          ..quadraticBezierTo(size.width * 0.35, size.height * 0.35, size.width * 0.45, size.height * 0.45);
        canvas.drawPath(eyeL, paint);
        final eyeR = Path()
          ..moveTo(size.width * 0.55, size.height * 0.45)
          ..quadraticBezierTo(size.width * 0.65, size.height * 0.35, size.width * 0.75, size.height * 0.45);
        canvas.drawPath(eyeR, paint);
        final smallSmile = Path()
          ..moveTo(size.width * 0.4, size.height * 0.65)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.7, size.width * 0.6, size.height * 0.65);
        canvas.drawPath(smallSmile, paint);
        break;

      case 5:
        canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), size.width * 0.05, eyePaint);
        canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), size.width * 0.05, eyePaint);
        final frownPath = Path()
          ..moveTo(size.width * 0.3, size.height * 0.75)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width * 0.7, size.height * 0.75);
        canvas.drawPath(frownPath, paint);
        break;
    }

    final hairPath = Path()
      ..moveTo(size.width * 0.5, 0)
      ..quadraticBezierTo(size.width * 0.6, -size.height * 0.1, size.width * 0.7, 0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

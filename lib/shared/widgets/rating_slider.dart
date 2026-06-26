import 'package:flutter/material.dart';
import 'dart:math' as math;

class RatingSlider extends StatefulWidget {
  final ValueChanged<double> onChanged;
  const RatingSlider({super.key, required this.onChanged});

  @override
  State<RatingSlider> createState() => _RatingSliderState();
}

class _RatingSliderState extends State<RatingSlider> with SingleTickerProviderStateMixin {
  double _value = 0.5;

  final List<Color> _colors = [
    const Color(0xFFA78BFA),
    const Color(0xFFF97316),
    const Color(0xFF92400E),
    const Color(0xFFFACC15),
    const Color(0xFF84CC16),
  ];

  Color _getColor(double value) {
    double scaledValue = value * (_colors.length - 1);
    int index = scaledValue.floor();
    int nextIndex = (index + 1).clamp(0, _colors.length - 1);
    double t = scaledValue - index;
    return Color.lerp(_colors[index], _colors[nextIndex], t)!;
  }

  Widget _getFace(double value) {
    int index = (value * 4).round();
    switch (index) {
      case 0: return _buildSadFace();
      case 1: return _buildDisappointedFace();
      case 2: return _buildNeutralFace();
      case 3: return _buildHappyFace();
      case 4: return _buildVeryHappyFace();
      default: return _buildNeutralFace();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) => Opacity(
                    opacity: 0.2,
                    child: _getStaticFace(index),
                  )),
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 0,
                  thumbShape: _CustomThumbShape(color: _getColor(_value), child: _getFace(_value)),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: _value,
                  onChanged: (val) {
                    setState(() => _value = val);
                    widget.onChanged(val);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getStaticFace(int index) {
    switch (index) {
      case 0: return const Icon(Icons.sentiment_very_dissatisfied, size: 24);
      case 1: return const Icon(Icons.sentiment_dissatisfied, size: 24);
      case 2: return const Icon(Icons.sentiment_neutral, size: 24);
      case 3: return const Icon(Icons.sentiment_satisfied, size: 24);
      case 4: return const Icon(Icons.sentiment_very_satisfied, size: 24);
      default: return const Icon(Icons.sentiment_neutral, size: 24);
    }
  }

  Widget _buildSadFace() {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _FacePainter(type: 0),
    );
  }

  Widget _buildDisappointedFace() {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _FacePainter(type: 1),
    );
  }

  Widget _buildNeutralFace() {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _FacePainter(type: 2),
    );
  }

  Widget _buildHappyFace() {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _FacePainter(type: 3),
    );
  }

  Widget _buildVeryHappyFace() {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _FacePainter(type: 4),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final Color color;
  final Widget child;

  _CustomThumbShape({required this.color, required this.child});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(50, 50);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path shadowPath = Path()..addOval(Rect.fromCircle(center: center, radius: 25));
    canvas.drawShadow(shadowPath, Colors.black, 4, true);

    canvas.drawCircle(center, 25, paint);

    final iconData = _getIconForValue(value);
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: 32,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  IconData _getIconForValue(double value) {
    int index = (value * 4).round();
    switch (index) {
      case 0: return Icons.sentiment_very_dissatisfied;
      case 1: return Icons.sentiment_dissatisfied;
      case 2: return Icons.sentiment_neutral;
      case 3: return Icons.sentiment_satisfied;
      case 4: return Icons.sentiment_very_satisfied;
      default: return Icons.sentiment_neutral;
    }
  }
}

class _FacePainter extends CustomPainter {
  final int type;
  _FacePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

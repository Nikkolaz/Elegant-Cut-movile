import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedLogoText extends StatefulWidget {
  final bool isDark;
  const AnimatedLogoText({super.key, required this.isDark});

  @override
  State<AnimatedLogoText> createState() => _AnimatedLogoTextState();
}

class _AnimatedLogoTextState extends State<AnimatedLogoText> with TickerProviderStateMixin {
  // Variable estática para persistir el estado durante la sesión de la app
  static bool _hasPlayedLogoAnimation = false;
  
  final String _fullText = 'Elegant Cut';
  
  String _currentText = '';
  bool _isMorphed = false;
  
  late AnimationController _morphController;
  late Animation<double> _tScale;
  late Animation<double> _tOpacity;
  late Animation<double> _faceScale;
  late Animation<double> _faceRotate;

  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _tScale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _morphController, curve: const Interval(0.0, 0.6, curve: Curves.easeInBack)),
    );
    _tOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _morphController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _faceScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: const Interval(0.5, 1.0, curve: Curves.elasticOut)),
    );
    _faceRotate = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _morphController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    // Lógica para que solo se ejecute una vez por sesión
    if (_hasPlayedLogoAnimation) {
      _currentText = _fullText;
      _isMorphed = true;
      _morphController.value = 1.0;
    } else {
      _startSequence();
      _hasPlayedLogoAnimation = true;
    }
  }

  void _startSequence() async {
    if (!mounted) return;

    for (int i = 0; i <= _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 140));
      if (mounted) {
        setState(() {
          _currentText = _fullText.substring(0, i);
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _morphController.forward();
      setState(() {
        _isMorphed = true;
      });
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final baseStyle = GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: 0,
    );

    final bool hasLastT = _currentText.length == _fullText.length;
    final String mainPart = hasLastT ? _currentText.substring(0, _currentText.length - 1) : _currentText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(mainPart, style: baseStyle),
        if (hasLastT)
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _morphController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _tOpacity.value,
                    child: Transform.scale(
                      scale: _tScale.value,
                      child: Text('t', style: baseStyle),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _morphController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _faceScale.value,
                    child: Transform.rotate(
                      angle: _faceRotate.value,
                      child: _buildMinimalFace(textColor),
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMinimalFace(Color color) {
    return Container(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _ProFacePainter(color: color),
      ),
    );
  }
}

class _ProFacePainter extends CustomPainter {
  final Color color;
  _ProFacePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    canvas.drawCircle(Offset(w * 0.3, h * 0.45), 1.5, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
    final winkPath = Path()
      ..moveTo(w * 0.6, h * 0.45)
      ..quadraticBezierTo(w * 0.7, h * 0.35, w * 0.8, h * 0.45);
    canvas.drawPath(winkPath, paint);
    final smilePath = Path()
      ..moveTo(w * 0.25, h * 0.75)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w * 0.75, h * 0.75);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

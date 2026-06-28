import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  final String fullText;
  final Duration animationDuration;

  const AnimatedText({
    super.key,
    required this.fullText,
    required this.animationDuration,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final totalChars = widget.fullText.length;
    final interval = widget.animationDuration ~/ totalChars;
    _timer = Timer.periodic(interval, (timer) {
      if (_currentIndex < totalChars) {
        setState(() {
          _displayedText = widget.fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: _buildSpans(),
        ),
      ),
    );
  }

  List<TextSpan> _buildSpans() {
    final List<TextSpan> spans = [];
    for (int i = 0; i < _displayedText.length; i++) {
      final char = _displayedText[i];
      if (char == ' ') {
        spans.add(const TextSpan(text: '  '));
      } else {
        spans.add(
          TextSpan(
            text: char,
            style: TextStyle(
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFFC5A028), Color(0xFFD4AF37)],
                ).createShader(const Rect.fromLTWH(0, 0, 30, 30)),
              shadows: const [
                Shadow(
                  color: Color(0x80C5A028),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      }
    }
    return spans;
  }
}

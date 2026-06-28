import 'package:flutter/material.dart';

class RotatingRings extends StatelessWidget {
  final AnimationController controller;

  const RotatingRings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: controller.value * 2 * 3.14159,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC5A028).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(color: const Color(0xFFC5A028), width: 2),
                      right:
                          BorderSide(color: const Color(0xFFD4AF37), width: 2),
                    ),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: -controller.value * 2 * 3.14159,
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC5A028).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFC5A028), width: 1.5),
                      left: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: controller.value * 2 * 3.14159,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC5A028).withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

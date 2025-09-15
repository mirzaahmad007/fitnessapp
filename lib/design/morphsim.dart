import 'dart:ui';
import 'package:flutter/material.dart';

class Morphism extends StatefulWidget {
  const Morphism({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  State<Morphism> createState() => _MorphismState();
}

class _MorphismState extends State<Morphism> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: widget.width,   // <-- using widget.width
        height: widget.height, // <-- using widget.height
        color: Colors.transparent,
        child: Stack(
          children: [
            // blur
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 4.0,
                sigmaY: 4.0,
              ),
              child: Container(),
            ),

            // glass effect with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  width: 2,
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
              child: Center(child: widget.child), // <-- using widget.child
            ),
          ],
        ),
      ),
    );
  }
}

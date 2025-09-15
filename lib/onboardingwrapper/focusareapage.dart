import 'package:flutter/material.dart';
import 'onboardingwrapper.dart';

class FocusAreaPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  FocusAreaPage({required this.onNext, this.onBack});

  @override
  _FocusAreaPageState createState() => _FocusAreaPageState();
}

class _FocusAreaPageState extends State<FocusAreaPage> {
  String? selected;

  // Labels + image target positions
  final List<Map<String, dynamic>> focusAreas = [
    {"label": "Full Body", "dy": 0.15},
    {"label": "Shoulders", "dy": 0.25},
    {"label": "Chest", "dy": 0.35},
    {"label": "Arms", "dy": 0.45},
    {"label": "Back", "dy": 0.55},
    {"label": "Stomach", "dy": 0.65},
    {"label": "Legs", "dy": 0.85},
  ];

  // text containers ke GlobalKeys → line start point nikalne ke liye
  final List<GlobalKey> _textKeys = [];

  @override
  void initState() {
    super.initState();
    for (var _ in focusAreas) {
      _textKeys.add(GlobalKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      step: 2,
      totalSteps: 11,
      title: "What's Your Focus Area?",
      subtitle: "Where would you like to channel your energy?",
      onNext: widget.onNext,
      onBack: widget.onBack,
      content: LayoutBuilder(
        builder: (context, constraints) {
          double imageHeight = constraints.maxHeight * 1.0;

          return Stack(
            children: [
              // ✅ Layout
              Row(
                children: [
                  // Left side: Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      focusAreas.asMap().entries.map((entry) {
                        int index = entry.key;
                        var area = entry.value;
                        bool isSelected =
                            selected == area["label"];

                        return Container(
                          key: _textKeys[index],
                          margin:
                          const EdgeInsets.symmetric(vertical: 10),
                          child: GestureDetector(
                            onTap: () => setState(
                                    () => selected = area["label"]),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.grey[300]!,
                                ),
                                borderRadius:
                                BorderRadius.circular(20),
                                color: isSelected
                                    ? Colors.purple
                                    .withOpacity(0.1)
                                    : Colors.white,
                              ),
                              child: Text(
                                area["label"],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Right side: Image
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        "assets/images/boy.png",
                        height: imageHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ Lines overlay (sabse upar)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: LinePainter(
                      focusAreas,
                      selected,
                      _textKeys,
                      imageHeight,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ✅ Custom painter for curved lines
class LinePainter extends CustomPainter {
  final List<Map<String, dynamic>> areas;
  final String? selected;
  final List<GlobalKey> textKeys;
  final double imageHeight;

  LinePainter(this.areas, this.selected, this.textKeys, this.imageHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.purple, Colors.purpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < areas.length; i++) {
      final area = areas[i];
      final renderBox =
      textKeys[i].currentContext?.findRenderObject()
      as RenderBox?;
      if (renderBox == null) continue;

      final start =
      renderBox.localToGlobal(Offset.zero); // Top-left
      final textCenter = Offset(
        start.dx + renderBox.size.width,
        start.dy + renderBox.size.height / 2,
      );

      // Convert to CustomPaint coordinate space
      final box = textKeys[i].currentContext!.findRenderObject()
      as RenderBox;
      final parentBox = box.parent as RenderBox;
      final localTextCenter =
      parentBox.globalToLocal(textCenter);

      final end = Offset(
        size.width * 0.75,
        imageHeight * area["dy"],
      );

      // Curv
      final controlPoint = Offset(
        (localTextCenter.dx + end.dx) / 2,
        localTextCenter.dy - 2,
      );

      final path = Path()
        ..moveTo(localTextCenter.dx, localTextCenter.dy)
        ..quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          end.dx,
          end.dy,
        );

      canvas.drawPath(path, paint);

      // Marker
      canvas.drawCircle(
        end,
        4,
        Paint()
          ..color = (selected == area["label"])
              ? Colors.purple
              : Colors.grey,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.selected != selected;
  }
}

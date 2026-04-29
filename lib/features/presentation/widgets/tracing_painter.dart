import 'package:flutter/material.dart';

class TracingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  TracingStroke({
    required this.points,
    this.color = Colors.blue,
    this.strokeWidth = 15.0,
  });
}

class TracingPainter extends CustomPainter {
  final List<TracingStroke> strokes;
  final String template; // The letter or number to trace
  final Color templateColor;

  TracingPainter({
    required this.strokes,
    required this.template,
    this.templateColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the template (the guideline)
    final textPainter = TextPainter(
      text: TextSpan(
        text: template,
        style: TextStyle(
          fontSize: size.height * 0.8,
          fontWeight: FontWeight.w100,
          color: templateColor.withValues(alpha: 0.2),
          fontFamily: 'Roboto', // Fallback, we can refine this later
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));

    // 2. Draw the child's strokes
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      paint.color = stroke.color;
      paint.strokeWidth = stroke.strokeWidth;

      if (stroke.points.length > 1) {
        final path = Path();
        path.moveTo(stroke.points[0].dx, stroke.points[0].dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      } else if (stroke.points.isNotEmpty) {
        // Draw a single point
        canvas.drawCircle(stroke.points[0], stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(covariant TracingPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.template != template;
  }
}

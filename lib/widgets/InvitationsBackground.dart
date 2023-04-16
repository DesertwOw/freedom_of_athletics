import 'package:flutter/material.dart';

class InvitationsBackground extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    _drawPentagone(canvas,size);
  }

  _drawPentagone(Canvas canvas, Size size){
    var path = Path();
    path.addPolygon([
      Offset(size.width, size.height/5),
      Offset(size.width,size.height),
      Offset(0.0, size.height),
      Offset(0.0, size.height/2.5),
    ],true);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return false;
  }
}
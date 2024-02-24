import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';

class BackgroundWave extends StatelessWidget {
  final double height;
  const BackgroundWave({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
      // decoration: BoxDecoration(
      //   color: AppColors.accent,
      // ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                color: AppVars.accent,
                height: height,
              ),
            ),
          ),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: AppVars.accent,
              height: height - 5,
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());
    var path = Path();
    path.lineTo(0, size.height - 80);
    var firstStart = Offset(size.width / 4, size.height - 100);
    var firstEnd = Offset(size.width / 2, size.height - 50.0);

    path.quadraticBezierTo(
      firstStart.dx,
      firstStart.dy,
      firstEnd.dx,
      firstEnd.dy,
    );

    var secondStart = Offset(size.width - (size.width / 3.5), size.height);
    var secondEnd = Offset(size.width, size.height - 10);

    path.quadraticBezierTo(
      secondStart.dx,
      secondStart.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

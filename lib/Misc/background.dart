import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class Background extends StatefulWidget {
  Background({super.key, required this.child});

  final Widget child;
  final String image = 'lib/assets/texture.jpg';

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _blurAnimation = Tween<double>(begin: 15.0, end: 40.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: BackgroundPainter(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Positioned.fill(
              child: AnimatedBuilder(
                  animation: _blurAnimation,
                  builder: (context, child) {
                    return BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value,
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    );
                  })),
          Positioned.fill(
            child: Image(
              image: AssetImage(widget.image),
              opacity: AlwaysStoppedAnimation(0.2),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
                margin: const EdgeInsets.only(top: 43), child: widget.child),
          ),
          if (ModalRoute.of(context)?.settings.name != '/')
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    final paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Color(0xFF372554);
    canvas.drawPath(mainBackground, paint);

    Path ovalPath = Path();
    ovalPath.addOval(Rect.fromCircle(center: Offset(100, 500), radius: 300));
    paint.color = Color.fromARGB(255, 92, 92, 154);
    canvas.drawPath(ovalPath, paint);

    Path topRightOvalPath = Path();
    topRightOvalPath.addOval(
        Rect.fromCircle(center: Offset(width - 100, 100), radius: 150));
    paint.color = Color.fromARGB(255, 212, 178, 216);
    canvas.drawPath(topRightOvalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

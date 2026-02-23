import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FanPage1 extends StatefulWidget {
  final VoidCallback onNext;

  const FanPage1({super.key, required this.onNext});

  @override
  State<FanPage1> createState() => _FanPage1State();
}

class _FanPage1State extends State<FanPage1> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _lightController;
  
  @override
  void initState() {
    super.initState();
    
    // Pulsing effect for text/crowd
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Rotating football
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Scanning stadium lights
    _lightController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.green.shade900,
              Colors.green.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Stadium Lights Background Effect
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _lightController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: StadiumLightsPainter(_lightController.value),
                    );
                  },
                ),
              ),

              // 2. Crowd Animation (Abstract moving particles)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.4,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CrowdPainter(_pulseController.value),
                    );
                  },
                ),
              ),

              // 3. Main Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // Rotating Football Centerpiece
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * 2 * math.pi,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sports_soccer,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),

                  // Text Content
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.05),
                        child: Text(
                          "FEEL THE ROAR",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 64,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.green.shade400,
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Your Local Team, Your Passion",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Next Button
                  GestureDetector(
                    onTap: widget.onNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade700],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "NEXT",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StadiumLightsPainter extends CustomPainter {
  final double animationValue;

  StadiumLightsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;

    // Create sweeping light beams
    final beamWidth = size.width * 0.2;
    final centerX = size.width * 0.5;
    final topY = 0.0;
    
    // Left Sweep
    final path1 = Path();
    final xOffset1 = size.width * 0.3 * math.sin(animationValue * math.pi);
    path1.moveTo(0, 0);
    path1.lineTo(centerX + xOffset1 - beamWidth, size.height);
    path1.lineTo(centerX + xOffset1 + beamWidth, size.height);
    path1.close();

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path1, paint);

    // Right Sweep (opposite direction)
    final path2 = Path();
    final xOffset2 = size.width * 0.3 * math.sin((animationValue + 0.5) * math.pi);
    path2.moveTo(size.width, 0);
    path2.lineTo(centerX + xOffset2 - beamWidth, size.height);
    path2.lineTo(centerX + xOffset2 + beamWidth, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant StadiumLightsPainter oldDelegate) => true;
}

class CrowdPainter extends CustomPainter {
  final double animationValue;

  CrowdPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent placement

    // Draw abstract crowd heads
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height * (0.3 + random.nextDouble() * 0.7);
      
      // Animate vertical bounce based on x position and animation value
      final bounce = math.sin((animationValue * 2 * math.pi) + (x / 50)) * 10;
      final y = baseY + bounce;

      final radius = 5.0 + random.nextDouble() * 10.0;
      
      paint.color = Colors.white.withOpacity(0.05 + random.nextDouble() * 0.15);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CrowdPainter oldDelegate) => true;
}

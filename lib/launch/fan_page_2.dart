import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FanPage2 extends StatefulWidget {
  final VoidCallback onComplete;

  const FanPage2({super.key, required this.onComplete});

  @override
  State<FanPage2> createState() => _FanPage2State();
}

class _FanPage2State extends State<FanPage2> with TickerProviderStateMixin {
  late AnimationController _playerController;
  late AnimationController _ballController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    
    // Player movement animation
    _playerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Ball energy trail animation
    _ballController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    // Button pulse
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _playerController.dispose();
    _ballController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.black,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Pitch Lines Background
              Positioned.fill(
                child: CustomPaint(
                  painter: PitchLinesPainter(),
                ),
              ),

              // 2. Dynamic Particles/Energy
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _ballController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: EnergyParticlesPainter(_ballController.value),
                    );
                  },
                ),
              ),

              // 3. Main Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Player Silhouette & Action
                  SizedBox(
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Energy Circle behind player
                        AnimatedBuilder(
                          animation: _playerController,
                          builder: (context, child) {
                            return Container(
                              width: 250 + (_playerController.value * 20),
                              height: 250 + (_playerController.value * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.purple.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Icon representing player action
                        AnimatedBuilder(
                          animation: _playerController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _playerController.value * -10),
                              child: const Icon(
                                Icons.directions_run_rounded,
                                size: 200,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),

                        // Moving Ball
                        AnimatedBuilder(
                          animation: _playerController,
                          builder: (context, child) {
                            final x = 80.0 + (_playerController.value * 40);
                            final y = 80.0 - (_playerController.value * 20);
                            return Transform.translate(
                              offset: Offset(x, y),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 10 + (_playerController.value * 10),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sports_soccer,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Text Content
                  Text(
                    "YOUR TEAM AWAITS",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 56,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.blue.shade400,
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Track Every Goal, Every Moment",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Launch/Start Button
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.05),
                        child: GestureDetector(
                          onTap: widget.onComplete,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade400, Colors.purple.shade600],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "LET'S GO!",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.rocket_launch, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

class PitchLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw abstract pitch lines graphic
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.drawCircle(center, size.width * 0.3, paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    
    // Diagonal lines for dynamic feel
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EnergyParticlesPainter extends CustomPainter {
  final double animationValue;

  EnergyParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(100);

    for (int i = 0; i < 20; i++) {
        // Particles moving upward diagonally
        final x = (random.nextDouble() * size.width);
        final progress = (animationValue + random.nextDouble()) % 1.0;
        final y = size.height - (progress * size.height);
        
        final color = i % 2 == 0 ? Colors.blue : Colors.purple;
        paint.color = color.withOpacity(1.0 - progress);
        
        final radius = (1.0 - progress) * 4.0;
        canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant EnergyParticlesPainter oldDelegate) => true;
}

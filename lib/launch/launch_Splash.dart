import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaunchSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const LaunchSplashScreen({super.key, required this.onComplete});

  @override
  State<LaunchSplashScreen> createState() => _LaunchSplashScreenState();
}

class _LaunchSplashScreenState extends State<LaunchSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _countdownController;
  late AnimationController _welcomeController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  // Confetti controllers for multiple blast directions
  late ConfettiController _confettiControllerCenter;
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;
  late ConfettiController _confettiControllerTop;

  int _countdown = 10;
  bool _showCountdown = false;
  bool _showWelcome = false;
  bool _showLaunchButton = false; // Show launch button after logo animation

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Countdown animation
    _countdownController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Welcome animation
    _welcomeController = AnimationController(
      duration: Duration(milliseconds: 5000),
      vsync: this,
    );
    
    // Pulse animation for launch button
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize confetti controllers
    _confettiControllerCenter = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _confettiControllerLeft = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _confettiControllerRight = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _confettiControllerTop = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _startSequence();
  }

  void _startSequence() async {
    // Show logo
    await Future.delayed(Duration(milliseconds: 500));
    _logoController.forward();

    // Wait for logo animation
    await Future.delayed(Duration(milliseconds: 2500));

    // Show launch button instead of auto-starting countdown
    setState(() => _showLaunchButton = true);
  }

  void _startCountdown() async {
    // Hide launch button and start countdown
    setState(() {
      _showLaunchButton = false;
      _showCountdown = true;
    });

    for (int i = 10; i > 0; i--) {
      setState(() => _countdown = i);
      _countdownController.reset();
      _countdownController.forward();
      await Future.delayed(Duration(seconds: 1));
    }

    // Show welcome with MASSIVE confetti blast
    setState(() {
      _showCountdown = false;
      _showWelcome = true;
    });

    _welcomeController.forward();

    // Trigger all confetti blasts with slight delays for wave effect
    _confettiControllerCenter.play();
    await Future.delayed(Duration(milliseconds: 200));
    _confettiControllerLeft.play();
    _confettiControllerRight.play();
    await Future.delayed(Duration(milliseconds: 200));
    _confettiControllerTop.play();

    // Move to onboarding
    await Future.delayed(Duration(milliseconds: 6500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _countdownController.dispose();
    _welcomeController.dispose();
    _pulseController.dispose();
    _confettiControllerCenter.dispose();
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();
    _confettiControllerTop.dispose();
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
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFF667EEA),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildParticle(index)),

            // CONFETTI BLASTERS - Multiple directions for spectacular effect!

            // Center blast (explosion outward)
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiControllerCenter,
                blastDirection: math.pi / 2, // Down
                maxBlastForce: 15,
                minBlastForce: 8,
                emissionFrequency: 0.02,
                numberOfParticles: 30,
                gravity: 0.08,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.purple,
                  Colors.pink,
                  Colors.teal,
                  Colors.amber,
                  Colors.cyan,
                ],
              ),
            ),

            // Left bottom blast (up-right diagonal)
            Align(
              alignment: Alignment.bottomLeft,
              child: ConfettiWidget(
                confettiController: _confettiControllerLeft,
                blastDirection: -math.pi / 4, // Up-Right
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 15,
                minBlastForce: 12,
                emissionFrequency: 0.03,
                numberOfParticles: 25,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.purple,
                  Colors.pink,
                ],
              ),
            ),

            // Right bottom blast (up-left diagonal)
            Align(
              alignment: Alignment.bottomRight,
              child: ConfettiWidget(
                confettiController: _confettiControllerRight,
                blastDirection: -3 * math.pi / 4, // Up-Left
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 15,
                minBlastForce: 10,
                emissionFrequency: 0.03,
                numberOfParticles: 20,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.purple,
                  Colors.pink,
                ],
              ),
            ),

            // Top center blast (fountain effect - down)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiControllerTop,
                blastDirection: math.pi / 2, // Down
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 10,
                minBlastForce: 5,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.12,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.purple,
                  Colors.pink,
                  Colors.teal,
                ],
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoFade.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/logo-removebg-preview.png",
                              height: 30,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 30),

                  // App name
                  FadeTransition(
                    opacity: _logoFade,
                    child: Text(
                      'UNITED AREECHOLA',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // FadeTransition(
                  //   opacity: _logoFade,
                  //   child: Text(
                  //     'Local Football, Digital Future',
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 14,
                  //       color: Colors.white.withOpacity(0.9),
                  //       letterSpacing: 1,
                  //     ),
                  //   ),
                  // ),

                  SizedBox(height: 80),

                  // Launch Button
                  if (_showLaunchButton)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final pulseScale = 1.0 + (_pulseController.value * 0.1);
                        return Transform.scale(
                          scale: pulseScale,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: GestureDetector(
                                  onTap: _startCountdown,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 50,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green[400]!,
                                          Colors.green[600]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.rocket_launch_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        SizedBox(width: 15),
                                        Text(
                                          'LAUNCH',
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                  // Countdown
                  if (_showCountdown)
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.5, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _countdownController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$_countdown',
                            style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Welcome message with confetti
                  if (_showWelcome)
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _welcomeController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Multiple animated emojis
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     _buildBouncingEmoji('🎉', 0),
                          //     SizedBox(width: 20),
                          //     // _buildBouncingEmoji('⚽', 100),
                          //     SizedBox(width: 20),
                          //     _buildBouncingEmoji('🎊', 100),
                          //   ],
                          // ),
                          // SizedBox(height: 30),

                          // Welcome text with glow and pulse effect
                          AnimatedBuilder(
                            animation: _welcomeController,
                            builder: (context, child) {
                              final pulseScale = 1.0 +
                                  (math.sin(_welcomeController.value *
                                          math.pi *
                                          7) *
                                      0.05);
                              return Transform.scale(
                                scale: pulseScale,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.6),
                                        blurRadius: 40,
                                        spreadRadius: 15,
                                      ),
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.4),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'WELCOME!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 20,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        Shadow(
                                          blurRadius: 40,
                                          color: Colors.amber.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 15),

                          // Subtitle with shimmer effect
                          FadeTransition(
                            opacity: _welcomeController,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '🚀 We\'re Live! Let\'s Go! 🚀',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Version at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _logoFade,
                child: Center(
                  child: Text(
                    'Launch Edition v1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBouncingEmoji(String emoji, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 10),
      builder: (context, value, child) {
        final bounceValue = math.sin(value * math.pi * 6);
        return Transform.translate(
          offset: Offset(0, -bounceValue * 15),
          child: Transform.rotate(
            angle: bounceValue * 0.3,
            child: Text(
              emoji,
              style: TextStyle(fontSize: 60),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(int index) {
    // final random = index * 0.1;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 2000 + (index * 100)),
      builder: (context, double value, child) {
        return Positioned(
          left: (index % 5) * MediaQuery.of(context).size.width / 5,
          top: value * MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 20 + (index % 3) * 10,
            ),
          ),
        );
      },
      onEnd: () {
        // setState(() {});
      },
    );
  }
}

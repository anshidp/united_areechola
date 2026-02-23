import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/team_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';

class PlayerShowcaseScreen extends ConsumerStatefulWidget {
  final AslTeamModel team;

  const PlayerShowcaseScreen({super.key, required this.team});

  @override
  ConsumerState<PlayerShowcaseScreen> createState() =>
      _PlayerShowcaseScreenState();
}

class _PlayerShowcaseScreenState extends ConsumerState<PlayerShowcaseScreen>
    with TickerProviderStateMixin {
  final players = StateProvider<List<PlayerModel>>((ref) => []);
  int currentPlayerIndex = 0;
  late AnimationController _revealController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late Animation<double> _circleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  
  // Countdown state
  bool _showLaunchButton = true;
  bool _isCountingDown = false;
  int _countdownValue = 3;

  @override
  void initState() {
    super.initState();
    loadPlayers();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Reveal animation controller
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Circle mask animation (expands from center)
    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Rotation animation (360° spin)
    _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Fade animation for stats
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.elasticOut,
      ),
    );

    _startRevealAnimation();
  }

  void _startRevealAnimation() {
    _revealController.reset();
    _rotationController.reset();
    _revealController.forward();
    _rotationController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void loadPlayers() async {
    try {
      final playersList = await ref
          .read(aslRepositoryProvider)
          .getPlayersList(widget.team.teamId ?? "");
      ref.read(players.notifier).state = playersList;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (playersList.isNotEmpty) {
          _startRevealAnimation();
        }
      }
    } catch (e) {
      // Handle error
      print("Error loading players: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextPlayer() {
    final playersList = ref.read(players);
    if (currentPlayerIndex < playersList.length - 1) {
      setState(() {
        currentPlayerIndex++;
      });
      _startRevealAnimation();
    }
  }

  void _previousPlayer() {
    final playersList = ref.read(players);
    if (currentPlayerIndex > 0) {
      setState(() {
        currentPlayerIndex--;
      });
      _startRevealAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersList = ref.watch(players);
    
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[900]!,
                Colors.green[800]!,
                Colors.grey[900]!,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }
    
    // Show empty state if no players
    if (playersList.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[900]!,
                Colors.green[800]!,
                Colors.grey[900]!,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 64,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Players Found',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    final currentPlayer = playersList[currentPlayerIndex];

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _previousPlayer();
          } else if (details.primaryVelocity! < 0) {
            _nextPlayer();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[900]!,
                Colors.green[800]!,
                Colors.grey[900]!,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Animated Background Particles
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ParticlesPainter(_particleController.value),
                      size: Size.infinite,
                    );
                  },
                ),

                // Main Content
                Column(
                  children: [
                    // Header
                    _buildHeader(),

                    // Player Showcase
                    Expanded(
                      child: Center(
                        child: _buildPlayerReveal(currentPlayer),
                      ),
                    ),

                    // Navigation Dots
                    _buildNavigationDots(),

                    const SizedBox(height: 20),
                  ],
                ),

                // Navigation Arrows
                _buildNavigationArrows(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEAM PLAYERS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
              Text(
                widget.team.name.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerReveal(PlayerModel player) {
    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Circular Background with Animation
            Transform.scale(
              scale: _circleAnimation.value,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.green[400]!.withOpacity(0.6),
                      Colors.green[700]!.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Rotating Circle Border
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _particleController.value * 2 * pi,
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CustomPaint(
                      painter: CircleDotsPainter(),
                    ),
                  ),
                );
              },
            ),

            // Player Image with Rotation
            Transform.rotate(
              angle: _rotationAnimation.value * 2 * pi,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: ClipOval(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: player.image.isNotEmpty
                          ? Image.network(
                              player.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlayerPlaceholder();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : _buildPlayerPlaceholder(),
                    ),
                  ),
                ),
              ),
            ),

            // Player Stats Card (Below)
            Positioned(
              bottom: -200,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, -_fadeAnimation.value * 50),
                  child: _buildPlayerStatsCard(player),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerStatsCard(PlayerModel player) {
    // Get stats from player model
    final goals = player.statics['goal']?.toString() ?? '0';
    final assists = player.statics['assist']?.toString() ?? '0';
    final appearances = player.appearences.toString();
    
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Position Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[400]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              player.possitionShort.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Player Name
          Text(
            player.name,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Position
          Text(
            player.possition,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(goals, 'GOALS', Colors.blue),
              _buildStatItem(assists, 'ASSISTS', Colors.orange),
              _buildStatItem(appearances, 'APPS', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationDots() {
    final playersList = ref.watch(players);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        playersList.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPlayerIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPlayerIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    final playersList = ref.watch(players);
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Arrow
          if (currentPlayerIndex > 0)
            Padding(
              padding: const EdgeInsets.all(20),
              child: IconButton(
                onPressed: _previousPlayer,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          const Spacer(),
          // Right Arrow
          if (currentPlayerIndex < playersList.length - 1)
            Padding(
              padding: const EdgeInsets.all(20),
              child: IconButton(
                onPressed: _nextPlayer,
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Painter for Background Particles
class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * 100) %
          size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

// Custom Painter for Circle Dots
class CircleDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

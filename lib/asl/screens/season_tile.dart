import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';

class EnhancedSeasonTile extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;

  const EnhancedSeasonTile({super.key, required this.seasonModel});

  @override
  ConsumerState<EnhancedSeasonTile> createState() => _EnhancedSeasonTileState();
}

class _EnhancedSeasonTileState extends ConsumerState<EnhancedSeasonTile>
    with TickerProviderStateMixin {
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    getTeams();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void getTeams() async {
    ref.read(teams.notifier).state = await ref
        .read(aslRepositoryProvider)
        .getTeams(widget.seasonModel.id ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(teams);
        return MouseRegion(
          onEnter: (_) {
            setState(() => isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => isHovered = false);
            _hoverController.reverse();
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isHovered ? 0.2 : 0.1),
                        blurRadius: isHovered ? 20 : 10,
                        offset: Offset(0, isHovered ? 10 : 5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.green[200]!,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        // Background Pattern
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green[100]!.withOpacity(0.3),
                            ),
                          ),
                        ),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with Logo and Title
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green[600]!,
                                          Colors.green[400]!
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.sports_soccer_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ASL',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                        Text(
                                          widget.seasonModel.seasonName
                                              .toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[800],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Stats Section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    _buildStatRow(
                                      'Date',
                                      DateFormat("dd MMM yyyy").format(
                                          widget.seasonModel.createdDate),
                                      Icons.calendar_today_rounded,
                                      Colors.blue[600]!,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatRow(
                                      'Teams',
                                      (widget.seasonModel.teams ?? [])
                                          .length
                                          .toString(),
                                      Icons.groups_rounded,
                                      Colors.orange[600]!,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatRow(
                                      'Winner',
                                      ref.read(teams)[
                                              widget.seasonModel.winner ??
                                                  ""] ??
                                          "TBD",
                                      Icons.emoji_events_rounded,
                                      Colors.amber[600]!,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatRow(
                                      'Runner Up',
                                      ref.read(teams)[
                                              widget.seasonModel.runner ??
                                                  ""] ??
                                          "TBD",
                                      Icons.military_tech_rounded,
                                      Colors.grey[600]!,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Hover Overlay
                        if (isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.green.withOpacity(0.1),
                                    Colors.green.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        color: Colors.green[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'View Details',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

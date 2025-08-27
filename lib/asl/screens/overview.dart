import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/screens/add_season_images.dart';
import 'package:united_areechola/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SeasonOverView extends StatefulWidget {
  SeasonModel? seasonModel;
  SeasonOverView({super.key, this.seasonModel});

  @override
  State<SeasonOverView> createState() => _SeasonOverViewState();
}

class _SeasonOverViewState extends State<SeasonOverView>
    with TickerProviderStateMixin {
  Map<String, dynamic> seasonImagestitle = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  void getSeasonImageTitle() async {
    final seasonSnap = await FirebaseFirestore.instance
        .collection(FirebaseConstants.seasonCollection)
        .doc(widget.seasonModel?.id)
        .get();
    if (seasonSnap.exists) {
      final seasonData = seasonSnap.data() ?? {};
      if (seasonData.containsKey("images")) {
        seasonImagestitle = seasonData['images'] ?? {};
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getSeasonImageTitle();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    final seasonImages = widget.seasonModel?.images;

    final awards = [
      AwardItem("WINNERS", seasonImages?.winners ?? "", AwardType.champion,
          Icons.emoji_events),
      AwardItem("RUNNERS", seasonImages?.runners ?? "", AwardType.runner,
          Icons.military_tech),
      AwardItem("BEST PLAYER", seasonImages?.bestplayer ?? "",
          AwardType.individual, Icons.person_4),
      AwardItem("BEST DEFENDER", seasonImages?.bestdefender ?? "",
          AwardType.individual, Icons.shield),
      AwardItem("BEST GOALKEEPER", seasonImages?.bestkeeper ?? "",
          AwardType.individual, Icons.sports_soccer),
      AwardItem("TOP SCORER", seasonImages?.topScorer ?? "",
          AwardType.individual, Icons.sports),
      AwardItem("BEST GOAL", seasonImages?.bestgoal ?? "", AwardType.special,
          Icons.videocam),
      AwardItem("MAN OF THE MATCH", seasonImages?.finalManofMatch ?? "",
          AwardType.special, Icons.star),
      AwardItem("BEST MANAGER", seasonImages?.bestmanager ?? "",
          AwardType.individual, Icons.person),
      AwardItem("FAIR PLAY", seasonImages?.fairPlaye ?? "", AwardType.special,
          Icons.handshake),
      AwardItem("MATCH OFFICIAL", seasonImages?.matchOfficial ?? "",
          AwardType.special, Icons.how_to_reg),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildHeader(scrWidth),
            _buildAwardsGrid(awards, scrWidth),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildHeader(double scrWidth) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFF0F172A),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Trophy icon with glow effect
              
                const SizedBox(height: 20),
                Text(
                  "ASL ${widget.seasonModel?.seasonName}".toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: kIsWeb ? scrWidth * 0.025 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Season Awards & Champions",
                  style: GoogleFonts.inter(
                    fontSize: kIsWeb ? scrWidth * 0.012 : 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                if (kIsWeb || true) // Enable for both web and mobile
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AwardGridPage(
                              seasonId: widget.seasonModel?.id ?? "",
                              awardTitles: seasonImagestitle,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_photo_alternate, size: 18),
                      label: const Text("Manage Awards"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildAwardsGrid(List<AwardItem> awards, double scrWidth) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                    curve: Curves.easeOutBack,
                  ),
                ),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0),
                      ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                      curve: Curves.easeOutBack,
                    ),
                  ),
                ),
                child: EnhancedAwardCard(
                  award: awards[index],
                  scrWidth: scrWidth,
                ),
              ),
            );
          },
          childCount: awards.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(scrWidth),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }

  int _getCrossAxisCount(double scrWidth) {
    if (scrWidth > 1200) return 4;
    if (scrWidth > 800) return 3;
    if (scrWidth > 600) return 2;
    return 1;
  }
}

enum AwardType { champion, runner, individual, special }

class AwardItem {
  final String title;
  final String imageUrl;
  final AwardType type;
  final IconData icon;

  AwardItem(this.title, this.imageUrl, this.type, this.icon);
}

class EnhancedAwardCard extends StatefulWidget {
  final AwardItem award;
  final double scrWidth;

  const EnhancedAwardCard({
    super.key,
    required this.award,
    required this.scrWidth,
  });

  @override
  State<EnhancedAwardCard> createState() => _EnhancedAwardCardState();
}

class _EnhancedAwardCardState extends State<EnhancedAwardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 8, end: 20).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Future<void> launchURL(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  Color _getTypeColor() {
    switch (widget.award.type) {
      case AwardType.champion:
        return const Color(0xFFFFD700); // Gold
      case AwardType.runner:
        return const Color(0xFFC0C0C0); // Silver
      case AwardType.individual:
        return const Color(0xFF3B82F6); // Blue
      case AwardType.special:
        return const Color(0xFF10B981); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) {
                return Card(
                  elevation: _elevationAnimation.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: _getTypeColor().withOpacity(0.3),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1F2937),
                          const Color(0xFF111827),
                        ],
                      ),
                      border: Border.all(
                        color: _getTypeColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildImageSection(),
                          _buildTitleSection(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // Main image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => launchURL(widget.award.imageUrl),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: widget.award.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.award.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.award.icon,
                                  size: 40,
                                  color: _getTypeColor(),
                                ),
                                const SizedBox(height: 8),
                                const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),
            // Type indicator badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getTypeColor().withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  widget.award.icon,
                  size: 16,
                  color: widget.award.type == AwardType.champion ||
                          widget.award.type == AwardType.runner
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
            // Hover overlay
            if (_isHovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _getTypeColor().withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTypeColor().withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.award.icon,
            size: 48,
            color: _getTypeColor(),
          ),
          const SizedBox(height: 12),
          Text(
            "No Image",
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getTypeColor().withOpacity(0.1),
            _getTypeColor().withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.award.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: kIsWeb ? widget.scrWidth * 0.012 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 30,
            decoration: BoxDecoration(
              color: _getTypeColor(),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

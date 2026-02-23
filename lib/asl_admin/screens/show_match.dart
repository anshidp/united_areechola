import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/asl_admin/screens/add_matches.dart';
import 'package:united_areechola/asl_admin/screens/update_match.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/utils/constants.dart';

class ShowMatch extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;
  const ShowMatch({super.key, required this.seasonModel});

  @override
  ConsumerState<ShowMatch> createState() => _ShowMatchState();
}

class _ShowMatchState extends ConsumerState<ShowMatch>
    with TickerProviderStateMixin {
  final teamAscoreController = TextEditingController();
  final teamBscoreController = TextEditingController();
  final selectWinningTeam = StateProvider<String?>((ref) => null);
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  // Responsive helper method
  bool get isLargeScreen => MediaQuery.of(context).size.width > 1024;
  bool get isMediumScreen => MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 1024;
  bool get isSmallScreen => MediaQuery.of(context).size.width <= 600;

  // Responsive font sizes
  double getResponsiveFontSize(double mobileSize, double tabletSize, double desktopSize) {
    if (isLargeScreen) return desktopSize;
    if (isMediumScreen) return tabletSize;
    return mobileSize;
  }

  // Responsive padding
  EdgeInsets getResponsivePadding() {
    if (isLargeScreen) return const EdgeInsets.all(32);
    if (isMediumScreen) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }

  Future<void> migrateGoals(String seasonId) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Load all players in this season
    final playersSnapshot = await firestore
        .collection(FirebaseConstants.seasonCollection)
        .doc(seasonId)
        .collection(FirebaseConstants.playerCollection)
        .get();

    final players = {
      for (var doc in playersSnapshot.docs)
        doc.id: {
          "name": doc.data()["name"],
          "teamId": doc.data()["teamId"],
        }
    };

    // 2. Load all teams in this season
    final teamsSnapshot = await firestore
        .collection(FirebaseConstants.seasonCollection)
        .doc(seasonId)
        .collection(FirebaseConstants.teamCollection)
        .get();

    final teams = {
      for (var doc in teamsSnapshot.docs) doc.id: doc.data()["name"]
    };

    // 3. Load all matches
    final matchesSnapshot = await firestore
        .collection(FirebaseConstants.seasonCollection)
        .doc(seasonId)
        .collection("matches")
        .get();

    for (var matchDoc in matchesSnapshot.docs) {
      final data = matchDoc.data();
      final goals = (data["goals"] ?? []) as List<dynamic>;

      if (goals.isNotEmpty && goals.first is Map) {
        final updatedGoals = goals.map((goal) {
          final playerId = goal["playerId"];
          final player = players[playerId] ?? {};
          final teamId = player["teamId"];
          final teamName = goal["team"];

          return {
            "playerId": playerId,
            "playerName": goal["playerName"] ?? player["name"] ?? "",
            "teamId": teamId ?? teams[teamName] ?? "",
            "teamName": teamName,
          };
        }).toList();

        await matchDoc.reference.update({"goals": updatedGoals});
        print("Updated match ${matchDoc.id}");
      }
    }
  }

  void getTeams() async {
    ref.read(teams.notifier).state = await ref
        .read(aslRepositoryProvider)
        .getTeams(widget.seasonModel.id ?? "");
  }

  @override
  void initState() {
    super.initState();
    getTeams();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _tabController = TabController(length: 4, vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MatchModel>>(
      stream: FirebaseFirestore.instance
          .collection('seasons')
          .doc(widget.seasonModel.id)
          .collection('matches')
          .where('delete', isEqualTo: false)
          .orderBy('createdDate', descending: false)
          .snapshots()
          .map((event) =>
              event.docs.map((e) => MatchModel.fromMap(e.data())).toList()),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }

        final matches = snapshot.data ?? [];
        bool isFinalMatch = matches.any((element) =>
            element.stage == GroupType.finalmatch.name &&
            element.status == MatchStatus.fulltime.name);

        final groupMatches = matches
            .where((element) => element.stage == GroupType.group.name)
            .toList();
        final quarterMatches = matches
            .where((element) => element.stage == GroupType.quarterfinal.name)
            .toList();
        final semiMatches = matches
            .where((element) => element.stage == GroupType.semifinal.name)
            .toList();
        final finalmatches = matches
            .where((element) => element.stage == GroupType.finalmatch.name)
            .toList();

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // _buildHeader(),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMatchesTab(
                              groupMatches, "Group Stage", Icons.groups),
                          _buildMatchesTab(quarterMatches, "Quarter Finals",
                              Icons.filter_4),
                          _buildMatchesTab(
                              semiMatches, "Semi Finals", Icons.filter_2),
                          _buildMatchesTab(
                              finalmatches, "Final", Icons.emoji_events),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isFinalMatch) _buildWinnerCelebration(matches),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: getResponsivePadding(),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E40AF),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: isLargeScreen ? 40 : (isMediumScreen ? 36 : 32),
                ),
              ),
              SizedBox(width: isLargeScreen ? 24 : 16),
              
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: GoogleFonts.inter(
          fontSize: getResponsiveFontSize(12, 14, 16),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: getResponsiveFontSize(12, 14, 16),
          fontWeight: FontWeight.w500,
        ),
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF3B82F6),
        indicatorWeight: 3,
        tabs: [
          Tab(
            text: "Group Stage",
            icon: Icon(Icons.groups, size: isLargeScreen ? 24 : 20),
          ),
          Tab(
            text: "Quarter Finals",
            icon: Icon(Icons.filter_4, size: isLargeScreen ? 24 : 20),
          ),
          Tab(
            text: "Semi Finals",
            icon: Icon(Icons.filter_2, size: isLargeScreen ? 24 : 20),
          ),
          Tab(
            text: "Final",
            icon: Icon(Icons.emoji_events, size: isLargeScreen ? 24 : 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab(
      List<MatchModel> matches, String stageName, IconData icon) {
    if (matches.isEmpty) {
      return _buildEmptyState(stageName, icon);
    }

    // Use GridView for large screens, ListView for smaller screens
    return SingleChildScrollView(
      padding: getResponsivePadding(),
      child: Column(
        children: [
          // _buildStageHeader(stageName, icon, matches.length),
          SizedBox(height: isLargeScreen ? 32 : 20),
          if (isLargeScreen)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.8,
              ),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return _buildEnhancedMatchCard(matches[index], index);
              },
            )
          else
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildEnhancedMatchCard(matches[index], index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStageHeader(String stageName, IconData icon, int matchCount) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: isLargeScreen ? 40 : 32),
          SizedBox(width: isLargeScreen ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stageName,
                  style: GoogleFonts.inter(
                    fontSize: getResponsiveFontSize(18, 22, 26),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "$matchCount ${matchCount == 1 ? 'Match' : 'Matches'}",
                  style: GoogleFonts.inter(
                    fontSize: getResponsiveFontSize(12, 14, 16),
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMatchCard(MatchModel match, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _getMatchStatusColor(match.status).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(teams);
          return Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            child: Column(
              children: [
                _buildMatchHeader(match, ref),
                SizedBox(height: isLargeScreen ? 20 : 16),
                _buildTeamsSection(match, ref),
                SizedBox(height: isLargeScreen ? 20 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildGoalScorers(match.matchId ?? "", match.teamA,
                          widget.seasonModel.id ?? "", ref),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildGoalScorers(match.matchId ?? "", match.teamB,
                          widget.seasonModel.id ?? "", ref),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildMatchInfo(match),
                if (isAdmin &&
                    kIsWeb &&
                    match.status == MatchStatus.ongoing.name) ...[
                  SizedBox(height: isLargeScreen ? 20 : 16),
                  _buildAdminActions(match, ref),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalScorers(
      String matchId, String teamId, String seasonId, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(aslRepositoryProvider).getgoalByteam(
            matchId: matchId,
            team: teamId,
            season: seasonId,
          ),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child:CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ));
        }

        if (asyncSnapshot.hasError) {
          return Text(
            "Error loading goals",
            style: GoogleFonts.inter(
              fontSize: getResponsiveFontSize(9, 10, 12),
              color: Colors.red[400],
            ),
            textAlign: TextAlign.center,
          );
        }

        if (asyncSnapshot.hasData) {
          final goalsData = asyncSnapshot.data ?? [];

          if (goalsData.isEmpty) {
            return Text(
              "No goals yet",
              style: GoogleFonts.inter(
                fontSize: getResponsiveFontSize(10, 11, 13),
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            );
          }

          return Column(
            children: goalsData.map<Widget>((goal) {
              final playerName = goal.goalTakerName ?? "";
              final type = goal.type ?? "goals"; // Default to goals if null
              
              Color bgColor;
              Color borderColor;
              Color textColor;
              Widget icon;

              if (type == "yellow") {
                bgColor = Colors.yellow[50]!;
                borderColor = Colors.yellow[200]!;
                textColor = Colors.yellow[900]!;
                icon = Icon(Icons.rectangle, color: Colors.yellow[700], size: 16);
              } else if (type == "red") {
                bgColor = Colors.red[50]!;
                borderColor = Colors.red[200]!;
                textColor = Colors.red[900]!;
                icon = const Icon(Icons.rectangle, color: Colors.red, size: 16);
              } else {
                // Goals, Penaltis
                bgColor = Colors.orange[50]!;
                borderColor = Colors.orange[200]!;
                textColor = Colors.orange[800]!;
                icon = Text(
                  "⚽",
                  style: TextStyle(fontSize: getResponsiveFontSize(11, 12, 14)),
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 12 : 8,
                  vertical: isLargeScreen ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        goal.isPenaltyGoal == true ? "$playerName (Pen)" : playerName,
                        style: GoogleFonts.inter(
                          fontSize: getResponsiveFontSize(10, 11, 13),
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMatchHeader(MatchModel match, WidgetRef ref) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 16 : 12,
            vertical: isLargeScreen ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: _getMatchStatusColor(match.status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            match.status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: getResponsiveFontSize(11, 12, 14),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsSection(MatchModel match, WidgetRef ref) {
    return Row(
      children: [
        // Team A
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  ref.read(teams)[match.teamA] ?? "Team A",
                  style: GoogleFonts.inter(
                    fontSize: getResponsiveFontSize(14, 16, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (match.status == MatchStatus.fulltime.name ||
                    match.teamAscore > 0 ||
                    match.teamBscore > 0) ...[
                  SizedBox(height: isLargeScreen ? 12 : 8),
                  Text(
                    match.teamAscore.toString(),
                    style: GoogleFonts.inter(
                      fontSize: getResponsiveFontSize(22, 26, 32),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // VS or Score Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 20 : 16),
          child: Column(
            children: [
              if (match.status == MatchStatus.fulltime.name ||
                  match.teamAscore > 0 ||
                  match.teamBscore > 0) ...[
                Text(
                  "VS",
                  style: GoogleFonts.inter(
                    fontSize: getResponsiveFontSize(12, 14, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ] else ...[
                Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                      size: isLargeScreen ? 24 : 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(match.kickoff),
                      style: GoogleFonts.inter(
                        fontSize: getResponsiveFontSize(12, 14, 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd').format(match.kickoff),
                      style: GoogleFonts.inter(
                        fontSize: getResponsiveFontSize(11, 12, 14),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Team B
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  ref.read(teams)[match.teamB] ?? "Team B",
                  style: GoogleFonts.inter(
                    fontSize: getResponsiveFontSize(14, 16, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (match.status == MatchStatus.fulltime.name ||
                    match.teamAscore > 0 ||
                    match.teamBscore > 0) ...[
                  SizedBox(height: isLargeScreen ? 12 : 8),
                  Text(
                    match.teamBscore.toString(),
                    style: GoogleFonts.inter(
                      fontSize: getResponsiveFontSize(22, 26, 32),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchInfo(MatchModel match) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.calendar_today,
              DateFormat('MMM dd, yyyy').format(match.kickoff)),
          _buildInfoItem(
              Icons.access_time, DateFormat('HH:mm').format(match.kickoff)),
          _buildInfoItem(Icons.sports_soccer, match.stage.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isLargeScreen ? 18 : 16, color: Colors.grey[600]),
        SizedBox(width: isLargeScreen ? 6 : 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: getResponsiveFontSize(11, 12, 14),
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminActions(MatchModel match, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showEndMatchDialog(match, ref),
            icon: Icon(Icons.sports_score, size: isLargeScreen ? 20 : 18),
            label: Text(
              "End Match",
              style: TextStyle(fontSize: getResponsiveFontSize(12, 14, 16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: isLargeScreen ? 16 : 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => showUpdateMatchDialog(context, match),
            icon: Icon(Icons.edit, size: isLargeScreen ? 20 : 18),
            label: Text(
              "Update",
              style: TextStyle(fontSize: getResponsiveFontSize(12, 14, 16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String stageName, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isLargeScreen ? 80 : 64, color: Colors.grey[400]),
          SizedBox(height: isLargeScreen ? 24 : 16),
          Text(
            "No matches in $stageName",
            style: GoogleFonts.inter(
              fontSize: getResponsiveFontSize(16, 18, 20),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCelebration(List<MatchModel> matches) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/winners.json',
          repeat: true,
          width: isLargeScreen ? 400 : (screenWidth * 0.3),
          height: isLargeScreen ? 400 : (screenHeight * 0.3),
        ),
        const SizedBox(height: 20),
        Container(
          width: isLargeScreen ? 600 : (screenWidth * 0.7),
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 20 : 12,
            horizontal: isLargeScreen ? 32 : 16,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(teams);
              return Center(
                child: Text(
                  "🏆 Champions: ${ref.read(teams)[getFinalWinner(matches)]} 🏆",
                  style: GoogleFonts.inter(
                    fontSize: getResponsiveFontSize(14, 18, 22),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getMatchStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fulltime':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'scheduled':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }

  void _showEndMatchDialog(MatchModel match, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    
    teamAscoreController.text = (match.teamAscore ?? 0).toString();
    teamBscoreController.text = (match.teamBscore ?? 0).toString();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, set) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "End Match",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: getResponsiveFontSize(18, 20, 24),
            ),
          ),
          content: SizedBox(
            width: isLargeScreen ? 500 : (w * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: teamAscoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(14, 16, 18),
                        ),
                        decoration: InputDecoration(
                          labelText: ref.read(teams)[match.teamA] ?? "Team A",
                          labelStyle: TextStyle(
                            fontSize: getResponsiveFontSize(12, 14, 16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 24 : 16),
                    Expanded(
                      child: TextFormField(
                        controller: teamBscoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(14, 16, 18),
                        ),
                        decoration: InputDecoration(
                          labelText: ref.read(teams)[match.teamB] ?? "Team B",
                          labelStyle: TextStyle(
                            fontSize: getResponsiveFontSize(12, 14, 16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isLargeScreen ? 24 : 16),
                if (int.parse(teamAscoreController.text) == 0 &&
                        int.parse(teamBscoreController.text) == 0 &&
                        match.stage == GroupType.semifinal.name ||
                    match.stage == GroupType.finalmatch.name)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 16 : 12,
                      vertical: isLargeScreen ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      focusColor: Colors.transparent,
                      underline: const SizedBox(),
                      isExpanded: true,
                      hint: Text(
                        "Select Winner",
                        style: GoogleFonts.poppins(
                          color: Color(0xffB6B6B6),
                          fontSize: getResponsiveFontSize(12, 14, 16),
                        ),
                      ),
                      value: (ref.watch(selectWinningTeam) ?? "").isEmpty
                          ? null
                          : ref.read(selectWinningTeam),
                      items: ref
                          .watch(teams)
                          .entries
                          .map(
                            (possition) => DropdownMenuItem<String>(
                              value: possition.key,
                              child: Text(
                                possition.value,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: getResponsiveFontSize(12, 14, 16),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        set(
                          () {
                            ref.read(selectWinningTeam.notifier).state = value;
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: getResponsiveFontSize(12, 14, 16)),
              ),
            ),
            ElevatedButton(
              onPressed: () => _endMatch(match, ref, w, h),
              child: Text(
                "End Match",
                style: TextStyle(fontSize: getResponsiveFontSize(12, 14, 16)),
              ),
            ),
          ],
        );
      }),
    );
  }

  void showUpdateMatchDialog(BuildContext context, MatchModel match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: UpdateMatch(matchModel: match),
      ),
    );
  }

  void _endMatch(MatchModel match, WidgetRef ref, double w, double h) async {
    bool isPenalty = int.parse(teamAscoreController.text) == 0 &&
            int.parse(teamBscoreController.text) == 0 &&
            match.stage == GroupType.semifinal.name ||
        match.stage == GroupType.finalmatch.name;
    print("is penalty: $isPenalty");
    if (teamAscoreController.text.isEmpty) {
      return showSnackBarToast(
          context, "Please enter ${ref.read(teams)[match.teamA]} Score", "red");
    } else if (teamBscoreController.text.isEmpty) {
      return showSnackBarToast(
          context, "Please enter ${ref.read(teams)[match.teamB]} Score", 'red');
    } else if (isPenalty) {
      if (ref.read(selectWinningTeam) == null) {
        return showSnackBarToast(context, "Please choose winner team", 'red');
      }
    }

    final confirm =
        await alert(context, "Do you want to end this match?", w, h);

    if (confirm && context.mounted) {
      ref.read(aslRepositoryProvider).updateMatchStat(
          seasonId: widget.seasonModel.id ?? "",
          winner: ref.read(selectWinningTeam) ?? "",
          context: context,
          w: w,
          h: h,
          currentStage: match.stage,
          matchId: match.matchId ?? "",
          teamA: match.teamA,
          teamB: match.teamB,
          teamAscore: int.parse(teamAscoreController.text),
          teamBscore: int.parse(teamBscoreController.text));
      if (context.mounted) {
        showSnackBarToast(context, "Player updated successfully", "green");
        Navigator.pop(context);
      }
    }
  }

  String getFinalWinner(List<MatchModel> matches) {
    final finalMatch = matches.firstWhere(
      (match) => match.stage == GroupType.finalmatch.name,
      orElse: () => MatchModel(
        goals: [],
        ispenalty: false,
        winner: "",
        seasonId: "",
        matchId: '',
        teamA: '',
        teamB: '',
        teamAscore: 0,
        teamBscore: 0,
        status: '',
        stage: '',
        kickoff: DateTime.now(),
        createdDate: DateTime.now(),
        delete: false,
      ),
    );

    if (finalMatch.matchId?.isEmpty ?? true) return 'Unknown Team';

    String winner = "";
    if (finalMatch.teamAscore == 0 && finalMatch.teamBscore == 0) {
      winner = finalMatch.winner ?? "";
    } else {
      winner = finalMatch.teamAscore > finalMatch.teamBscore
          ? finalMatch.teamA
          : finalMatch.teamB;
    }

    return winner.isEmpty ? 'Unknown Team' : winner;
  }
}
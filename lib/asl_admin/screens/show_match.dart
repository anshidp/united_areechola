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

      // Only process if it's a list of playerIds (Strings)
      if (goals.isNotEmpty && goals.first is Map) {
        final updatedGoals = goals.map((goal) {
          final playerId = goal["playerId"];
          final player = players[playerId] ?? {};
          final teamId = player["teamId"];
          final teamName = goal["team"]; // already stored name

          return {
            "playerId": playerId,
            "playerName": goal["playerName"] ?? player["name"] ?? "",
            "teamId": teamId ?? teams[teamName] ?? "",
            "teamName": teamName,
          };
        }).toList();

        // print("updatedGoals: $updatedGoals");

        // Update match document
        await matchDoc.reference.update({"goals": updatedGoals});
        print("Updated match ${matchDoc.id}");
      }
    }
  }

  void getTeams() async {
    ref.read(teams.notifier).state = await ref
        .read(aslRepositoryProvider)
        .getTeams(widget.seasonModel.id ?? "");

    // await migrateGoals(widget.seasonModel.id ?? "");
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
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

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
                    _buildHeader(w),
                    _buildTabBar(w),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMatchesTab(
                              groupMatches, "Group Stage", h, w, Icons.groups),
                          _buildMatchesTab(quarterMatches, "Quarter Finals", h,
                              w, Icons.filter_4),
                          _buildMatchesTab(
                              semiMatches, "Semi Finals", h, w, Icons.filter_2),
                          _buildMatchesTab(
                              finalmatches, "Final", h, w, Icons.emoji_events),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isFinalMatch) _buildWinnerCelebration(matches, w, h),
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

  Widget _buildHeader(double w) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tournament Matches",
                    style: GoogleFonts.inter(
                      fontSize: kIsWeb ? w * 0.02 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "ASL ${widget.seasonModel.seasonName}",
                    style: GoogleFonts.inter(
                      fontSize: kIsWeb ? w * 0.01 : 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(double w) {
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
          fontSize: kIsWeb ? w * 0.01 : 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: kIsWeb ? w * 0.01 : 14,
          fontWeight: FontWeight.w500,
        ),
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF3B82F6),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: "Group Stage", icon: Icon(Icons.groups, size: 20)),
          Tab(text: "Quarter Finals", icon: Icon(Icons.filter_4, size: 20)),
          Tab(text: "Semi Finals", icon: Icon(Icons.filter_2, size: 20)),
          Tab(text: "Final", icon: Icon(Icons.emoji_events, size: 20)),
        ],
      ),
    );
  }

  Widget _buildMatchesTab(List<MatchModel> matches, String stageName, double h,
      double w, IconData icon) {
    if (matches.isEmpty) {
      return _buildEmptyState(stageName, icon);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStageHeader(stageName, icon, matches.length, w),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matches.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildEnhancedMatchCard(matches[index], h, w, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStageHeader(
      String stageName, IconData icon, int matchCount, double w) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stageName,
                  style: GoogleFonts.inter(
                    fontSize: kIsWeb ? w * 0.015 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "$matchCount ${matchCount == 1 ? 'Match' : 'Matches'}",
                  style: GoogleFonts.inter(
                    fontSize: kIsWeb ? w * 0.01 : 14,
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

  Widget _buildEnhancedMatchCard(
      MatchModel match, double h, double w, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildMatchHeader(match, ref, w),
                const SizedBox(height: 16),
                _buildTeamsSection(match, ref, w),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildGoalScorers(match.matchId ?? "", match.teamA,
                        widget.seasonModel.id ?? "", ref, w),
                    _buildGoalScorers(match.matchId ?? "", match.teamB,
                        widget.seasonModel.id ?? "", ref, w),
                  ],
                ),
                const SizedBox(height: 10),
                _buildMatchInfo(match, w),
                if (isAdmin &&
                    kIsWeb &&
                    match.status == MatchStatus.ongoing.name) ...[
                  const SizedBox(height: 16),
                  _buildAdminActions(match, ref, w, h),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalScorers(
      String matchId, String teamId, String seasonId, WidgetRef ref, double w) {
    return FutureBuilder(
      future: ref.read(aslRepositoryProvider).getgoalByteam(
            matchId: matchId,
            team: teamId,
            season: seasonId,
          ),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          );
        }

        if (asyncSnapshot.hasError) {
          return Text(
            "Error loading goals",
            style: GoogleFonts.inter(
              fontSize: kIsWeb ? w * 0.008 : 10,
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
                fontSize: kIsWeb ? w * 0.009 : 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            );
          }

          return Column(
            children: goalsData.map<Widget>((goal) {
              final playerName = goal.goalTakerName ?? "";
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "⚽",
                      style: TextStyle(fontSize: kIsWeb ? w * 0.01 : 12),
                    ),
                    const SizedBox(width: 4),
                    goal.isPenaltyGoal == true
                        ? Flexible(
                            child: Text(
                              "$playerName (Pen)",
                              style: GoogleFonts.inter(
                                fontSize: kIsWeb ? w * 0.009 : 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[800],
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Flexible(
                            child: Text(
                              playerName,
                              style: GoogleFonts.inter(
                                fontSize: kIsWeb ? w * 0.009 : 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[800],
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

  Widget _buildMatchHeader(MatchModel match, WidgetRef ref, double w) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getMatchStatusColor(match.status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            match.status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: kIsWeb ? w * 0.008 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsSection(MatchModel match, WidgetRef ref, double w) {
    return Row(
      children: [
        // Team A
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  ref.read(teams)[match.teamA] ?? "Team A",
                  style: GoogleFonts.inter(
                    fontSize: kIsWeb ? w * 0.012 : 16,
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
                  const SizedBox(height: 8),
                  Text(
                    match.teamAscore.toString(),
                    style: GoogleFonts.inter(
                      fontSize: kIsWeb ? w * 0.02 : 24,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (match.status == MatchStatus.fulltime.name ||
                  match.teamAscore > 0 ||
                  match.teamBscore > 0) ...[
                Text(
                  "VS",
                  style: GoogleFonts.inter(
                    fontSize: kIsWeb ? w * 0.01 : 14,
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
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(match.kickoff),
                      style: GoogleFonts.inter(
                        fontSize: kIsWeb ? w * 0.01 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd').format(match.kickoff),
                      style: GoogleFonts.inter(
                        fontSize: kIsWeb ? w * 0.008 : 12,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  ref.read(teams)[match.teamB] ?? "Team B",
                  style: GoogleFonts.inter(
                    fontSize: kIsWeb ? w * 0.012 : 16,
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
                  const SizedBox(height: 8),
                  Text(
                    match.teamBscore.toString(),
                    style: GoogleFonts.inter(
                      fontSize: kIsWeb ? w * 0.02 : 24,
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

  Widget _buildMatchInfo(MatchModel match, double w) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.calendar_today,
              DateFormat('MMM dd, yyyy').format(match.kickoff), w),
          _buildInfoItem(
              Icons.access_time, DateFormat('HH:mm').format(match.kickoff), w),
          _buildInfoItem(Icons.sports_soccer, match.stage.toUpperCase(), w),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, double w) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: kIsWeb ? w * 0.008 : 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminActions(
      MatchModel match, WidgetRef ref, double w, double h) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showEndMatchDialog(match, ref, w, h),
            icon: const Icon(Icons.sports_score, size: 18),
            label: const Text("End Match"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => showUpdateMatchDialog(context, match),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Update"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
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
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No matches in $stageName",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCelebration(List<MatchModel> matches, double w, double h) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/winners.json',
          repeat: true,
          width: w * 0.3,
          height: h * 0.3,
        ),
        const SizedBox(height: 20),
        Container(
          width: w * 0.7,
          height: h * 0.04,
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
                    fontSize: kIsWeb ? w * 0.02 : 15,
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

  void _showEndMatchDialog(
      MatchModel match, WidgetRef ref, double w, double h) {
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
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: w * 0.4,
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
                        decoration: InputDecoration(
                          labelText: ref.read(teams)[match.teamA] ?? "Team A",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: teamBscoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText: ref.read(teams)[match.teamB] ?? "Team B",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: h * 0.03)),
                if (int.parse(teamAscoreController.text) == 0 &&
                        int.parse(teamBscoreController.text) == 0 &&
                        match.stage == GroupType.semifinal.name ||
                    match.stage == GroupType.finalmatch.name)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: w * 0.02),
                        width: w * 0.2,
                        height: h * 0.06,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(w * 0.02),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                            focusColor: Colors.transparent,
                            underline: const SizedBox(),
                            hint: Text(
                              "Select Winner",
                              style: GoogleFonts.poppins(
                                color: Color(0xffB6B6B6),
                                fontSize: w * 0.008,
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
                                        fontSize: w * 0.008,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              set(
                                () {
                                  ref.read(selectWinningTeam.notifier).state =
                                      value;
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                Padding(padding: EdgeInsets.only(top: h * 0.03)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _endMatch(match, ref, w, h),
              child: const Text("End Match"),
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
    // Implementation for ending match

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

    //! update match
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/Models/notification_model.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class UpdateMatch extends ConsumerStatefulWidget {
  final MatchModel matchModel;
  const UpdateMatch({super.key, required this.matchModel});

  @override
  ConsumerState<UpdateMatch> createState() => _UpdateMatchState();
}

class _UpdateMatchState extends ConsumerState<UpdateMatch>
    with TickerProviderStateMixin {
  final players = StateProvider<List<PlayerModel>>((ref) => []);
  final teamPlayers = StateProvider<List<PlayerModel>>((ref) => []);
  final selectPlayer = StateProvider<String?>((ref) => null);
  final selectPlayerName = StateProvider<String?>((ref) => null);
  final selectAssisterName = StateProvider<String?>((ref) => null);
  final selectTeam = StateProvider<String?>((ref) => null);
  final selectAssister = StateProvider<String?>((ref) => null);
  final selectEvent = StateProvider<String?>((ref) => null);
  final isLoading = StateProvider<bool>((ref) => false);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<EventOption> events = [
    EventOption(
      type: PlayerTypes.penalty.name,
      icon: Icons.flash_on_outlined,
      color: Color.fromARGB(255, 7, 131, 219),
      label: 'Penalty',
    ),
    EventOption(
      type: PlayerTypes.goals.name,
      icon: Icons.sports_soccer,
      color: Color(0xFF10B981),
      label: 'Goal',
    ),
    EventOption(
      type: PlayerTypes.yellow.name,
      icon: Icons.warning,
      color: Color(0xFFF59E0B),
      label: 'Yellow Card',
    ),
    EventOption(
      type: PlayerTypes.red.name,
      icon: Icons.error,
      color: Color(0xFFEF4444),
      label: 'Red Card',
    ),
  ];

  void getAllPlayers() async {
    ref.read(players.notifier).state = await ref
        .read(aslRepositoryProvider)
        .getTeamPlayers(widget.matchModel.teamA, widget.matchModel.teamB,
            widget.matchModel.seasonId);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    getAllPlayers();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      width: isTablet ? 600 : double.infinity,
      constraints: BoxConstraints(maxHeight: 700),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildMatchInfo(),
                      SizedBox(height: 32),
                      _buildPlayerSection(),
                      SizedBox(height: 24),
                      _buildEventSection(),
                      if (_shouldShowAssister()) ...[
                        SizedBox(height: 24),
                        _buildAssisterSection(),
                      ],
                      SizedBox(height: 32),
                      _buildActionButtons(),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Match',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Add match events and statistics',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Match Information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Team A vs Team B',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Player',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 12),
        _buildPlayerDropdown(),
      ],
    );
  }

  Widget _buildPlayerDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD1D5DB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(
            Icons.person_rounded,
            color: Color(0xFF9CA3AF),
          ),
        ),
        hint: Text(
          'Choose a player',
          style: GoogleFonts.poppins(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
        value: (ref.watch(selectPlayer) ?? "").isEmpty
            ? null
            : ref.read(selectPlayer),
        items: ref
            .watch(players)
            .map((player) => DropdownMenuItem<String>(
                  value: player.playerId,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.sports_soccer,
                          size: 16,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        player.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (value) {
          ref.read(selectPlayer.notifier).state = value;
          ref.read(selectTeam.notifier).state = ref
              .read(players)
              .firstWhere((element) => element.playerId == value)
              .teamId;
          ref.read(selectPlayerName.notifier).state = ref
              .read(players)
              .firstWhere((element) => element.playerId == value)
              .name;

          // Reset dependent selections
          ref.read(selectEvent.notifier).state = null;
          ref.read(selectAssister.notifier).state = null;
        },
      ),
    );
  }

  Widget _buildEventSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Event Type',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: events
              .map((event) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: event == events.last ? 0 : 8,
                      ),
                      child: _buildEventCard(event),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEventCard(EventOption event) {
    final isSelected = ref.watch(selectEvent) == event.type;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 200),
      tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, double value, child) {
        return GestureDetector(
          onTap: (ref.watch(selectPlayer) ?? "").isEmpty
              ? null
              : () async {
                  ref.read(selectEvent.notifier).state = event.type;
                  print("eventName: ${ref.read(selectEvent)}");
                  if (event.type == PlayerTypes.goals.name) {
                    ref.read(teamPlayers.notifier).state = await ref
                        .read(aslRepositoryProvider)
                        .getSpecificTeamPlayers(
                            seasonId: widget.matchModel.seasonId,
                            teamId: ref.read(selectTeam) ?? "");
                  }
                },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Color.lerp(Colors.white, event.color.withOpacity(0.1), value),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color.lerp(Color(0xFFE5E7EB), event.color, value)!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: event.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      Color(0xFFF3F4F6),
                      event.color.withOpacity(0.2),
                      value,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    event.icon,
                    color: Color.lerp(Color(0xFF9CA3AF), event.color, value),
                    size: 20,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  event.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color.lerp(Color(0xFF6B7280), event.color, value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssisterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Assister',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFD1D5DB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(
                Icons.assist_walker_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ),
            hint: Text(
              'Choose an assister (optional)',
              style: GoogleFonts.poppins(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
            value: (ref.watch(selectAssister) ?? "").isEmpty
                ? null
                : ref.read(selectAssister),
            items: ref
                .watch(teamPlayers)
                .where((element) => element.playerId != ref.read(selectPlayer))
                .map((player) => DropdownMenuItem<String>(
                      value: player.playerId,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            player.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              ref.read(selectAssister.notifier).state = value;
              ref.read(selectAssisterName.notifier).state = ref
                  .read(teamPlayers)
                  .firstWhere((element) => element.playerId == value)
                  .name;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Color(0xFFD1D5DB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _canUpdate() ? _updateMatch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.update_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Update Match',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _shouldShowAssister() {
    return (ref.watch(selectPlayer) ?? "").isNotEmpty &&
        (ref.watch(selectEvent) ?? "").isNotEmpty &&
        ref.watch(selectEvent) == PlayerTypes.goals.name;
  }

  bool _canUpdate() {
    final hasPlayer = (ref.watch(selectPlayer) ?? "").isNotEmpty;
    final hasEvent = (ref.watch(selectEvent) ?? "").isNotEmpty;
    final needsAssister = ref.watch(selectEvent) == PlayerTypes.goals.name;
    final hasAssister = (ref.watch(selectAssister) ?? "").isNotEmpty;

    if (!hasPlayer || !hasEvent) return false;
    if (needsAssister && !hasAssister) return false;

    return true;
  }

  Future<void> _updateMatch() async {
    try {
      String dialogContent = "";
      String notificationBody = "";

      final event = ref.read(selectEvent);
      final playerName = ref.read(selectPlayerName) ?? "";
      final assisterName = ref.read(selectAssisterName) ?? "";
      if (event == PlayerTypes.penalty.name) {
        dialogContent =
            "പെനാൽറ്റി അടിച്ചത് ${ref.read(selectPlayerName)} ആണെന്ന് ഉറപ്പാണോ ?";
        notificationBody = "🅿️ $playerName scored a penalty";
      } else if (event == PlayerTypes.goals.name) {
        dialogContent =
            "ഗോൾ അടിച്ചത് ${ref.read(selectPlayerName)} ഉം അസിസ്റ്റ് ചെയ്തത് ${ref.read(selectAssisterName)} ഉം ആണെന്ന് ഉറപ്പാണോ ?";
        notificationBody =
            "⚽ $playerName scored a goal (Assist: $assisterName)";
      } else if (event == PlayerTypes.yellow.name) {
        dialogContent =
            "yellow കാർഡ് കിട്ടിയത് ${ref.read(selectPlayerName)} ആണെന്ന് ഉറപ്പാണോ ?";
        notificationBody = "🟨 $playerName received a yellow card";
      } else if (event == PlayerTypes.red.name) {
        dialogContent =
            "red കാർഡ് കിട്ടിയത് ${ref.read(selectPlayerName)} ആണെന്ന് ഉറപ്പാണോ ?";
        notificationBody = "🟥 $playerName received a red card";
      }
      final confirm = await _showConfirmDialog(content: dialogContent);
      if (!confirm) return;

      await ref.read(aslRepositoryProvider).updatePlayerStat(
            isPenaltyGoal: (ref.read(selectEvent) == PlayerTypes.penalty.name),
            playerName: ref.read(selectPlayerName) ?? "",
            seasonId: widget.matchModel.seasonId,
            assister: ref.read(selectAssister) ?? "",
            matchId: widget.matchModel.matchId ?? "",
            selectTeam: ref.read(selectTeam) ?? "",
            teamA: widget.matchModel.teamA,
            teamB: widget.matchModel.teamB,
            playerId: ref.read(selectPlayer) ?? "",
            type: ref.read(selectEvent) ?? "",
          );
      final notification = NotificationModel(
        delete: false,
        title: "Match update",
        body: notificationBody,
        createdDate: DateTime.now(),
      );
      final noti = db.collection('notification').doc();
      notification.id = noti.id;
      noti.set(notification.toMap());

      if (mounted) {
        showSnackBarToast(context, "Match updated successfully", "green");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBarToast(context, "Failed to update match", "red");
      }
    }
  }

  Future<bool> _showConfirmDialog({required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                SizedBox(width: 12),
                Text(
                  'Confirm Update',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF10B981),
                ),
                child: Text(
                  'Confirm',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class EventOption {
  final String type;
  final IconData icon;
  final Color color;
  final String label;

  EventOption({
    required this.type,
    required this.icon,
    required this.color,
    required this.label,
  });
}

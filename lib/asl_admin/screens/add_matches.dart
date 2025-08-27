import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

enum GroupType { group, semifinal, quarterfinal, finalmatch }

class AddMatches extends ConsumerStatefulWidget {
  const AddMatches({super.key});

  @override
  ConsumerState<AddMatches> createState() => _AddMatchesState();
}

class _AddMatchesState extends ConsumerState<AddMatches>
    with TickerProviderStateMixin {
  final teamA = StateProvider<String?>((ref) => null);
  final teamB = StateProvider<String?>((ref) => null);
  final selectStage = StateProvider<String?>((ref) => null);
  final selectSeason = StateProvider<String?>((ref) => null);
  final selectGroup = StateProvider<String?>((ref) => null);
  final startTime = StateProvider<TimeOfDay?>((ref) => null);
  final startDate = StateProvider<DateTime?>((ref) => null);
  final statTimeController = TextEditingController();
  final statDateController = TextEditingController();
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> stage = [
    GroupType.group.name,
    GroupType.semifinal.name,
    GroupType.quarterfinal.name,
    GroupType.finalmatch.name
  ];
  final List<String> group = ["A", "B"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
    getSeason();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void getSeason() async {
    ref.read(seasons.notifier).state =
        await ref.read(aslRepositoryProvider).getSeasons();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(w * 0.02),
            child: Center(
              child: Column(
                children: [
                  // Header Section
                  _buildHeaderSection(w),
                  SizedBox(height: w * 0.03),

                  // Main Content
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side - Match Form
                      Expanded(
                        flex: 2,
                        child: _buildMatchForm(w, h),
                      ),
                      SizedBox(width: w * 0.02),

                      // Right Side - Match Preview
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.025),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.015),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(w * 0.01),
            ),
            child: Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: w * 0.03,
            ),
          ),
          SizedBox(width: w * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Schedule',
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.022,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Create and schedule new matches for your tournament',
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.012,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchForm(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.025),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.01),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(w * 0.008),
                ),
                child: Icon(
                  Icons.event_note,
                  color: const Color(0xFF10B981),
                  size: w * 0.02,
                ),
              ),
              SizedBox(width: w * 0.015),
              Text(
                "Match Details",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.02,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.03),

          // Season Selection
          _buildModernDropdownField(
            label: "Season",
            icon: Icons.calendar_view_month,
            value: (ref.watch(selectSeason) ?? "").isEmpty
                ? null
                : ref.read(selectSeason),
            items: ref.watch(seasons).entries.map((pos) {
              return DropdownMenuItem<String>(
                value: pos.key,
                child: Text(
                  pos.value,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E293B),
                    fontSize: w * 0.011,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) async {
              ref.read(selectSeason.notifier).state = value;
              ref.read(teams.notifier).state = await ref
                  .read(aslRepositoryProvider)
                  .getTeams(ref.read(selectSeason) ?? "");
            },
          ),
          SizedBox(height: w * 0.025),

          // Teams Selection Row
          Row(
            children: [
              Expanded(
                child: _buildModernDropdownField(
                  label: "Team A",
                  icon: Icons.shield,
                  value:
                      (ref.watch(teamA) ?? "").isEmpty ? null : ref.read(teamA),
                  items: ref.watch(teams).entries.map((pos) {
                    return DropdownMenuItem<String>(
                      value: pos.key,
                      child: Text(
                        pos.value,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E293B),
                          fontSize: w * 0.011,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(teamA.notifier).state = value;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: w * 0.02, vertical: w * 0.02),
                padding: EdgeInsets.all(w * 0.01),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'VS',
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.012,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
              Expanded(
                child: _buildModernDropdownField(
                  label: "Team B",
                  icon: Icons.shield,
                  value:
                      (ref.watch(teamB) ?? "").isEmpty ? null : ref.read(teamB),
                  items: ref.watch(teams).entries.map((pos) {
                    return DropdownMenuItem<String>(
                      value: pos.key,
                      child: Text(
                        pos.value,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E293B),
                          fontSize: w * 0.011,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(teamB.notifier).state = value;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.025),

          // Date and Time Row
          Row(
            children: [
              Expanded(
                child: _buildModernDateField(
                  label: "Match Date",
                  icon: Icons.calendar_today,
                  controller: statDateController,
                  onTap: () async {
                    final pickDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      initialDate: DateTime.now(),
                      lastDate: DateTime(2050),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF3B82F6),
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF1E293B),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickDate != null) {
                      ref.read(startDate.notifier).state = pickDate;
                      statDateController.text =
                          DateFormat("MMM dd, yyyy").format(pickDate);
                    }
                  },
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: _buildModernDateField(
                  label: "Match Time",
                  icon: Icons.access_time,
                  controller: statTimeController,
                  onTap: () async {
                    final pickTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF3B82F6),
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF1E293B),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickTime != null) {
                      ref.read(startTime.notifier).state = pickTime;
                      statTimeController.text = pickTime.format(context);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.025),

          // Stage Selection
          _buildModernDropdownField(
            label: "Match Stage",
            icon: Icons.military_tech,
            value: (ref.watch(selectStage) ?? "").isEmpty
                ? null
                : ref.read(selectStage),
            items: stage.map((st) {
              return DropdownMenuItem<String>(
                value: st,
                child: Row(
                  children: [
                    _getStageIcon(st),
                    SizedBox(width: w * 0.01),
                    Text(
                      _getStageDisplayName(st),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E293B),
                        fontSize: w * 0.011,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              ref.read(selectStage.notifier).state = value;
            },
          ),
          SizedBox(height: w * 0.04),

          // Create Match Button
          SizedBox(
            width: double.infinity,
            height: w * 0.04,
            child: ElevatedButton(
              onPressed: () => _handleMatchCreation(context, w, h),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.015),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.white.withOpacity(0.1);
                    }
                    return null;
                  },
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle,
                    size: w * 0.015,
                  ),
                  SizedBox(width: w * 0.01),
                  Text(
                    "Create Match",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: w * 0.013,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchPreview(double w) {
    final teamAName = ref.watch(teamA) != null
        ? ref.watch(teams)[ref.watch(teamA)] ?? "Team A"
        : "Team A";
    final teamBName = ref.watch(teamB) != null
        ? ref.watch(teams)[ref.watch(teamB)] ?? "Team B"
        : "Team B";
    final selectedDate = ref.watch(startDate);
    final selectedTime = ref.watch(startTime);
    final selectedStage = ref.watch(selectStage);

    return Container(
      padding: EdgeInsets.all(w * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.025),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.008),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(w * 0.006),
                ),
                child: Icon(
                  Icons.visibility,
                  color: const Color(0xFF8B5CF6),
                  size: w * 0.018,
                ),
              ),
              SizedBox(width: w * 0.01),
              Text(
                "Match Preview",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.016,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.025),

          // Match Card Preview
          Container(
            padding: EdgeInsets.all(w * 0.02),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(w * 0.015),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Stage Badge
                if (selectedStage != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: w * 0.01, vertical: w * 0.005),
                    decoration: BoxDecoration(
                      color: _getStageColor(selectedStage),
                      borderRadius: BorderRadius.circular(w * 0.01),
                    ),
                    child: Text(
                      _getStageDisplayName(selectedStage),
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.009,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(height: w * 0.015),

                // Teams
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: w * 0.04,
                            height: w * 0.04,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shield,
                              color: const Color(0xFF3B82F6),
                              size: w * 0.02,
                            ),
                          ),
                          SizedBox(height: w * 0.008),
                          Text(
                            teamAName.length > 10
                                ? '${teamAName.substring(0, 10)}...'
                                : teamAName,
                            style: GoogleFonts.poppins(
                              fontSize: w * 0.01,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: w * 0.015, vertical: w * 0.008),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(w * 0.008),
                      ),
                      child: Text(
                        'VS',
                        style: GoogleFonts.poppins(
                          fontSize: w * 0.012,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: w * 0.04,
                            height: w * 0.04,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shield,
                              color: const Color(0xFFEF4444),
                              size: w * 0.02,
                            ),
                          ),
                          SizedBox(height: w * 0.008),
                          Text(
                            teamBName.length > 10
                                ? '${teamBName.substring(0, 10)}...'
                                : teamBName,
                            style: GoogleFonts.poppins(
                              fontSize: w * 0.01,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.02),

                // Date and Time
                if (selectedDate != null || selectedTime != null)
                  Container(
                    padding: EdgeInsets.all(w * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(w * 0.01),
                    ),
                    child: Column(
                      children: [
                        if (selectedDate != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: w * 0.012,
                                color: const Color(0xFF6B7280),
                              ),
                              SizedBox(width: w * 0.005),
                              Text(
                                DateFormat("MMM dd, yyyy").format(selectedDate),
                                style: GoogleFonts.poppins(
                                  fontSize: w * 0.01,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        if (selectedTime != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: w * 0.012,
                                color: const Color(0xFF6B7280),
                              ),
                              SizedBox(width: w * 0.005),
                              Text(
                                selectedTime.format(context),
                                style: GoogleFonts.poppins(
                                  fontSize: w * 0.01,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: w * 0.02),

          // Quick Stats
          Container(
            padding: EdgeInsets.all(w * 0.015),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(w * 0.01),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Info',
                  style: GoogleFonts.poppins(
                    fontSize: w * 0.011,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
                SizedBox(height: w * 0.01),
                _buildInfoRow('Status', 'Scheduled', Icons.schedule),
                _buildInfoRow('Duration', '90 minutes', Icons.timer),
                _buildInfoRow('Type', 'Regular Match', Icons.sports_soccer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.003),
      child: Row(
        children: [
          Icon(
            icon,
            size: MediaQuery.of(context).size.width * 0.01,
            color: const Color(0xFF64748B),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.008),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).size.width * 0.009,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).size.width * 0.009,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontSize: MediaQuery.of(context).size.width * 0.012,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.008),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.width * 0.01),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF9CA3AF),
                    size: MediaQuery.of(context).size.width * 0.015,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Text(
                    "Select $label",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9CA3AF),
                      fontSize: MediaQuery.of(context).size.width * 0.011,
                    ),
                  ),
                ],
              ),
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF3B82F6),
                size: MediaQuery.of(context).size.width * 0.02,
              ),
              items: items,
              onChanged: onChanged,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.015,
                vertical: MediaQuery.of(context).size.width * 0.005,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDateField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontSize: MediaQuery.of(context).size.width * 0.012,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.008),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            readOnly: true,
            onTap: onTap,
            controller: controller,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E293B),
              fontSize: MediaQuery.of(context).size.width * 0.011,
            ),
            decoration: InputDecoration(
              hintText: "Select $label",
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: MediaQuery.of(context).size.width * 0.011,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: MediaQuery.of(context).size.width * 0.015,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.01),
                borderSide:
                    const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.01),
                borderSide:
                    const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.015,
                vertical: MediaQuery.of(context).size.width * 0.012,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Icon _getStageIcon(String stage) {
    switch (stage) {
      case 'group':
        return const Icon(Icons.groups, color: Color(0xFF10B981), size: 16);
      case 'quarterfinal':
        return const Icon(Icons.filter_4, color: Color(0xFFF59E0B), size: 16);
      case 'semifinal':
        return const Icon(Icons.filter_2, color: Color(0xFFEF4444), size: 16);
      case 'finalmatch':
        return const Icon(Icons.emoji_events,
            color: Color(0xFF8B5CF6), size: 16);
      default:
        return const Icon(Icons.sports_soccer,
            color: Color(0xFF6B7280), size: 16);
    }
  }

  String _getStageDisplayName(String stage) {
    switch (stage) {
      case 'group':
        return 'Group Stage';
      case 'quarterfinal':
        return 'Quarter Final';
      case 'semifinal':
        return 'Semi Final';
      case 'finalmatch':
        return 'Final Match';
      default:
        return stage.toUpperCase();
    }
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'group':
        return const Color(0xFF10B981);
      case 'quarterfinal':
        return const Color(0xFFF59E0B);
      case 'semifinal':
        return const Color(0xFFEF4444);
      case 'finalmatch':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _handleMatchCreation(BuildContext context, double w, double h) {
    if (ref.read(teamA) == null) {
      return showSnackBarToast(context, "Please choose Team A", "red");
    } else if (ref.read(teamB) == null) {
      return showSnackBarToast(context, "Please choose Team B", "red");
    } else if (ref.read(teamA) == ref.read(teamB)) {
      return showSnackBarToast(
          context, "Team A and Team B cannot be the same", "red");
    } else if (statDateController.text.isEmpty) {
      return showSnackBarToast(context, "Please choose Start Date", "red");
    } else if (statTimeController.text.isEmpty) {
      return showSnackBarToast(context, "Please choose Start Time", "red");
    } else if (ref.read(selectStage) == null) {
      return showSnackBarToast(context, "Please select match stage", "red");
    }

    final matchModel = MatchModel(
      seasonId: ref.read(selectSeason) ?? "",
      ispenalty: false,
      winner: "",
      stage: ref.read(selectStage) ?? "",
      goals: [],
      createdDate: DateTime.now(),
      delete: false,
      teamA: ref.read(teamA) ?? "",
      teamB: ref.read(teamB) ?? "",
      kickoff: DateTime(
        ref.read(startDate)!.year,
        ref.read(startDate)!.month,
        ref.read(startDate)!.day,
        ref.read(startTime)!.hour,
        ref.read(startTime)!.minute,
      ),
      status: MatchStatus.ongoing.name,
      teamAscore: 0,
      teamBscore: 0,
    );

    ref
        .read(aslRepositoryProvider)
        .addNewMatch(matchModel, ref.read(selectSeason) ?? "");

    if (context.mounted) {
      showSnackBarToast(context, "Match created successfully! 🎉", "green");
      _resetForm();
    }
  }

  void _resetForm() {
    ref.read(teamA.notifier).state = null;
    ref.read(teamB.notifier).state = null;
    ref.read(selectStage.notifier).state = null;
    ref.read(startTime.notifier).state = null;
    ref.read(startDate.notifier).state = null;
    statTimeController.clear();
    statDateController.clear();
  }
}

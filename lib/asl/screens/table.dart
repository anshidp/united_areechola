import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/model/team_model.dart';
import 'package:united_areechola/common/common.dart';

class TeamTable extends StatefulWidget {
  final SeasonModel seasonModel;
  const TeamTable({super.key, required this.seasonModel});

  @override
  State<TeamTable> createState() => _TeamTableState();
}

class _TeamTableState extends State<TeamTable> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFE),
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: StreamBuilder<List<AslTeamModel>>(
        stream: FirebaseFirestore.instance
            .collection('seasons')
            .doc(widget.seasonModel.id)
            .collection('teams')
            .where('delete', isEqualTo: false)
            .snapshots()
            .map(
              (event) => event.docs
                  .map((e) => AslTeamModel.fromMap(e.data()))
                  .toList(),
            ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          final teams = (snapshot.data ?? [])
            ..sort((a, b) {
              // Sort by points first, then by goal difference
              if (b.point != a.point) {
                return b.point.compareTo(a.point);
              }
              final aGD = (a.goalsFor ?? 0) - (a.goalsAgainst ?? 0);
              final bGD = (b.goalsFor ?? 0) - (b.goalsAgainst ?? 0);
              return bGD.compareTo(aGD);
            });

          final groupATeams = teams.where((team) => team.group == 'A').toList();
          final groupBTeams = teams.where((team) => team.group == 'B').toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // _buildSeasonHeader(),
                // SizedBox(height: 24),
                _buildGroupTable('Group A', groupATeams, Color(0xFF3B82F6)),
                SizedBox(height: 24),
                _buildGroupTable('Group B', groupBTeams, Color(0xFF10B981)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeasonHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Deep blue
            Color(0xFF3B82F6), // Bright blue
            Color(0xFF8B5CF6), // Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'League Table',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            widget.seasonModel.seasonName ?? 'Season',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTable(
      String groupName, List<AslTeamModel> teams, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Group Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  groupName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${teams.length} Teams',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Table Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: IntrinsicWidth(
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 30),
                        SizedBox(
                          width: 200,
                          child: Text(
                            'Team',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        _buildFixedHeaderCell('PL'),
                        _buildFixedHeaderCell('W'),
                        _buildFixedHeaderCell('D'),
                        _buildFixedHeaderCell('L'),
                        _buildFixedHeaderCell('GF'),
                        _buildFixedHeaderCell('GA'),
                        _buildFixedHeaderCell('GD'),
                        _buildFixedHeaderCell('PTS'),
                      ],
                    ),
                  ),

                  // ✅ FIXED: Replaced ListView.separated with Column
                  // This allows IntrinsicWidth to correctly calculate the width of the table
                  Column(
                    children: List.generate(teams.length, (index) {
                      final team = teams[index];
                      final position = index + 1;

                      return Column(
                        children: [
                          _buildTeamRow(team, position, accentColor),
                          // Add separator manually except for the last item
                          if (index < teams.length - 1)
                            Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedHeaderCell(String text) {
    return SizedBox(
      width: 50,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(AslTeamModel team, int position, Color accentColor) {
    final goalsFor = team.goalsFor ?? 0;
    final goalsAgainst = team.goalsAgainst ?? 0;
    final goalDifference = goalsFor - goalsAgainst;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: position <= 3 ? accentColor.withOpacity(0.05) : Colors.white,
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: position <= 3 ? accentColor : Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$position',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 6),

          // Team Info - Fixed width
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      ImageConstants.clubLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    team.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          _buildFixedStatCell(team.playedMatch.toString()),
          _buildFixedStatCell(team.win.toString(),
              isHighlight: true, color: Color(0xFF10B981)),
          _buildFixedStatCell(team.draw.toString()),
          _buildFixedStatCell(team.lose.toString(),
              isHighlight: true, color: Color(0xFFEF4444)),
          _buildFixedStatCell(goalsFor.toString()),
          _buildFixedStatCell(goalsAgainst.toString()),
          _buildFixedGoalDifferenceCell(goalDifference),
          _buildFixedPointsCell(team.point.toString(), accentColor),
        ],
      ),
    );
  }

  Widget _buildStatCell(String value,
      {bool isHighlight = false, Color? color}) {
    return Expanded(
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlight ? color?.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isHighlight ? color : Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedStatCell(String value,
      {bool isHighlight = false, Color? color}) {
    return SizedBox(
      width: 50,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlight ? color?.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isHighlight ? color : Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalDifferenceCell(int goalDifference) {
    final isPositive = goalDifference > 0;
    final isNegative = goalDifference < 0;
    final displayValue = isPositive ? '+$goalDifference' : '$goalDifference';

    return Expanded(
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPositive
                ? Color(0xFF10B981).withOpacity(0.1)
                : isNegative
                    ? Color(0xFFEF4444).withOpacity(0.1)
                    : Color(0xFF94A3B8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            displayValue,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPositive
                  ? Color(0xFF10B981)
                  : isNegative
                      ? Color(0xFFEF4444)
                      : Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedGoalDifferenceCell(int goalDifference) {
    final isPositive = goalDifference > 0;
    final isNegative = goalDifference < 0;
    final displayValue = isPositive ? '+$goalDifference' : '$goalDifference';

    return SizedBox(
      width: 50,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPositive
                ? Color(0xFF10B981).withOpacity(0.1)
                : isNegative
                    ? Color(0xFFEF4444).withOpacity(0.1)
                    : Color(0xFF94A3B8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            displayValue,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPositive
                  ? Color(0xFF10B981)
                  : isNegative
                      ? Color(0xFFEF4444)
                      : Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCell(String points, Color accentColor) {
    return Expanded(
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            points,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedPointsCell(String points, Color accentColor) {
    return SizedBox(
      width: 50,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            points,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading teams...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.sports_soccer,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No teams found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Teams will appear here once added',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFEF4444),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Error loading teams',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Please try again later',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

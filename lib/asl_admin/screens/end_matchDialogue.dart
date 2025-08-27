import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';

class EndMatchDialog extends StatefulWidget {
  final MatchModel match;
  final WidgetRef ref;
  final Function(MatchModel, WidgetRef, double, double) onEndMatch;
  final TextEditingController teamAscoreController;
  final TextEditingController teamBscoreController;
  final Map<String, String> teams;

  const EndMatchDialog({
    Key? key,
    required this.match,
    required this.ref,
    required this.onEndMatch,
    required this.teamAscoreController,
    required this.teamBscoreController,
    required this.teams,
  }) : super(key: key);

  @override
  State<EndMatchDialog> createState() => _EndMatchDialogState();
}

class _EndMatchDialogState extends State<EndMatchDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isProcessing = false;
  String? _winner;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
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
      begin: Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);

    // Listen to score changes to determine winner
    widget.teamAscoreController.addListener(_updateWinner);
    widget.teamBscoreController.addListener(_updateWinner);
    _updateWinner();
  }

  void _updateWinner() {
    final scoreA = int.tryParse(widget.teamAscoreController.text) ?? 0;
    final scoreB = int.tryParse(widget.teamBscoreController.text) ?? 0;
    
    setState(() {
      if (scoreA > scoreB) {
        _winner = 'A';
      } else if (scoreB > scoreA) {
        _winner = 'B';
      } else {
        _winner = 'Draw';
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: isTablet ? 500 : screenWidth * 0.9,
            constraints: BoxConstraints(maxWidth: 500),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildContent(screenWidth, screenHeight),
                _buildActions(screenWidth, screenHeight),
              ],
            ),
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
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Match',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Enter final scores to complete the match',
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

  Widget _buildContent(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMatchInfo(),
          SizedBox(height: 24),
          _buildScoreSection(),
          if (_winner != null) ...[
            SizedBox(height: 24),
            _buildWinnerSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_rounded,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Match is about to end - Enter final scores',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
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
          Text(
            'Final Score',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTeamScoreCard(
                  teamName: widget.teams[widget.match.teamA] ?? "Team A",
                  controller: widget.teamAscoreController,
                  isWinning: _winner == 'A',
                  teamId: 'A',
                ),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'VS',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTeamScoreCard(
                  teamName: widget.teams[widget.match.teamB] ?? "Team B",
                  controller: widget.teamBscoreController,
                  isWinning: _winner == 'B',
                  teamId: 'B',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreCard({
    required String teamName,
    required TextEditingController controller,
    required bool isWinning,
    required String teamId,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: isWinning ? 1.0 : 0.0),
      builder: (context, double value, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.lerp(
              Color(0xFFF8FAFC),
              Color(0xFF10B981).withOpacity(0.1),
              value,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color.lerp(
                Color(0xFFE2E8F0),
                Color(0xFF10B981),
                value,
              )!,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Color(0xFF3B82F6).withOpacity(0.1),
                        Color(0xFF10B981).withOpacity(0.2),
                        value,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sports_soccer,
                      color: Color.lerp(
                        Color(0xFF3B82F6),
                        Color(0xFF10B981),
                        value,
                      ),
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      teamName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.lerp(
                          Color(0xFF374151),
                          Color(0xFF10B981),
                          value,
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isWinning)
                    Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFFA726),
                      size: 16,
                    ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.lerp(
                    Color(0xFF1E293B),
                    Color(0xFF10B981),
                    value,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 24,
                    color: Color(0xFF9CA3AF),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWinnerSection() {
    if (_winner == null) return SizedBox.shrink();

    Color winnerColor = _winner == 'Draw' 
        ? Color(0xFF6B7280) 
        : Color(0xFF10B981);
    
    String winnerText = _winner == 'Draw' 
        ? 'Match ends in a Draw!' 
        : '${_winner == 'A' ? widget.teams[widget.match.teamA] : widget.teams[widget.match.teamB]} Wins!';

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  winnerColor.withOpacity(0.1),
                  winnerColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: winnerColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _winner == 'Draw' ? Icons.handshake : Icons.emoji_events,
                  color: winnerColor,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  winnerText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: winnerColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
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
              onPressed: _isProcessing ? null : () => _handleEndMatch(screenWidth, screenHeight),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ending...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'End Match',
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
      ),
    );
  }

  Future<void> _handleEndMatch(double screenWidth, double screenHeight) async {
    final confirm = await _showConfirmDialog();
    if (!confirm) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate processing
      widget.onEndMatch(widget.match, widget.ref, screenWidth, screenHeight);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 12),
            Text(
              'Confirm End Match',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to end this match with the following scores?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.teams[widget.match.teamA]} ${widget.teamAscoreController.text}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  Text(' - ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Text(
                    '${widget.teamBscoreController.text} ${widget.teams[widget.match.teamB]}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Color(0xFFEF4444),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
            ),
            child: Text('End Match'),
          ),
        ],
      ),
    ) ?? false;
  }
}
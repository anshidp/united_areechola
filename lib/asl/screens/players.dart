import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/common/common.dart';

class Players extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;
  const Players({super.key, required this.seasonModel});

  @override
  ConsumerState<Players> createState() => _PlayersState();
}

class _PlayersState extends ConsumerState<Players> with TickerProviderStateMixin {
  final searchPlayers = StateProvider<String>((ref) => "");
  final sortBy = StateProvider<String>((ref) => "goals");
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header Section
          _buildHeader(size),
          
          // Players List/Table
          Expanded(
            child: _buildPlayersList(size),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Stats
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[600]!, Colors.green[400]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Players Statistics',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        widget.seasonModel.seasonName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Search and Filter Row
            Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        ref.read(searchPlayers.notifier).state = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search players by name...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                                onPressed: () {
                                  searchController.clear();
                                  ref.read(searchPlayers.notifier).state = '';
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ref.watch(sortBy),
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.green[600]),
                          items: [
                            DropdownMenuItem(value: 'goals', child: Text('Sort by Goals')),
                            DropdownMenuItem(value: 'assists', child: Text('Sort by Assists')),
                            DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(sortBy.notifier).state = value;
                            }
                          },
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersList(Size size) {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(searchPlayers);
        ref.watch(sortBy);
        
        return StreamBuilder<List<PlayerModel>>(
          stream: FirebaseFirestore.instance
              .collection('seasons')
              .doc(widget.seasonModel.id)
              .collection("players")
              .where('delete', isEqualTo: false)
              .where('search',
                  arrayContains: ref.read(searchPlayers).isEmpty
                      ? null
                      : ref.read(searchPlayers).toUpperCase())
              .snapshots()
              .map(
                (event) => event.docs
                    .map(
                      (e) => PlayerModel.fromMap(e.data()),
                    )
                    .toList(),
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final players = _sortPlayers(snapshot.data!, ref.read(sortBy));

            return SlideTransition(
              position: _slideAnimation,
              child: size.width > 800 
                  ? _buildPlayersTable(players, size)
                  : _buildPlayersCards(players),
            );
          },
        );
      },
    );
  }

  List<PlayerModel> _sortPlayers(List<PlayerModel> players, String sortBy) {
    switch (sortBy) {
      case 'goals':
        return players
          ..sort((a, b) => (b.statics['goal'] ?? 0).compareTo((a.statics['goal'] ?? 0)));
      case 'assists':
        return players
          ..sort((a, b) => (b.statics['assist'] ?? 0).compareTo((a.statics['assist'] ?? 0)));
      case 'name':
        return players..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      default:
        return players;
    }
  }

  Widget _buildPlayersTable(List<PlayerModel> players, Size size) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[500]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.leaderboard_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Player Leaderboard (${players.length} Players)',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Table Content
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 60,
                dataRowHeight: 70,
                border: TableBorder.all(color: Colors.transparent),
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                columns: [
                  DataColumn(
                    label: _buildColumnHeader('Rank', Icons.military_tech_rounded),
                  ),
                  DataColumn(
                    label: _buildColumnHeader('Player', Icons.person_rounded),
                  ),
                  DataColumn(
                    label: _buildColumnHeader('Team', Icons.groups_rounded),
                  ),
                  DataColumn(
                    label: _buildColumnHeader('Goals', Icons.sports_soccer_rounded),
                  ),
                  DataColumn(
                    label: _buildColumnHeader('Assists', Icons.handshake_rounded),
                  ),
                  DataColumn(
                    label: _buildColumnHeader('Yellow', Icons.rectangle_rounded),
                  ),
                  if (kIsWeb)
                    DataColumn(
                      label: _buildColumnHeader('Red', Icons.rectangle_rounded),
                    ),
                ],
                rows: List.generate(players.length, (index) {
                  final player = players[index];
                  final playerStat = player.statics;
                  final isTopScorer = index == 0;
                  
                  return DataRow(
                    color: MaterialStateProperty.all(
                      isTopScorer ? Colors.amber[50] : Colors.white,
                    ),
                    cells: [
                      DataCell(_buildRankCell(index + 1, isTopScorer)),
                      DataCell(_buildPlayerCell(player)),
                      DataCell(_buildTeamCell(player)),
                      DataCell(_buildStatCell(playerStat['goal'] ?? 0, Colors.green)),
                      DataCell(_buildStatCell(playerStat['assist'] ?? 0, Colors.blue)),
                      DataCell(_buildStatCell(playerStat['yelloCard'] ?? 0, Colors.yellow[700]!)),
                      if (kIsWeb)
                        DataCell(_buildStatCell(playerStat['redCard'] ?? 0, Colors.red)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersCards(List<PlayerModel> players) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isTopScorer = index == 0;
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _buildPlayerCard(player, index + 1, isTopScorer),
            );
          },
        );
      },
    );
  }

  Widget _buildPlayerCard(PlayerModel player, int rank, bool isTopScorer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isTopScorer
            ? LinearGradient(
                colors: [Colors.amber[50]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isTopScorer ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTopScorer
            ? Border.all(color: Colors.amber[300]!, width: 2)
            : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Header
          Row(
            children: [
              // Rank Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isTopScorer ? Colors.amber[400] : Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#$rank',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isTopScorer ? Colors.white : Colors.green[700],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Player Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name ?? 'Unknown Player',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('seasons')
                          .doc(widget.seasonModel.id)
                          .collection('teams')
                          .doc(player.teamId)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        return Text(
                          snapshot.data?['name'] ?? 'Unknown Team',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              if (isTopScorer)
                Icon(Icons.emoji_events_rounded, color: Colors.amber[600], size: 28),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMobileStatItem(
                'Goals',
                (player.statics['goal'] ?? 0).toString(),
                Icons.sports_soccer_rounded,
                Colors.green,
              ),
              _buildMobileStatItem(
                'Assists',
                (player.statics['assist'] ?? 0).toString(),
                Icons.handshake_rounded,
                Colors.blue,
              ),
              _buildMobileStatItem(
                'Yellow',
                (player.statics['yelloCard'] ?? 0).toString(),
                Icons.rectangle_rounded,
                Colors.yellow[700]!,
              ),
              if (kIsWeb)
                _buildMobileStatItem(
                  'Red',
                  (player.statics['redCard'] ?? 0).toString(),
                  Icons.rectangle_rounded,
                  Colors.red,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildRankCell(int rank, bool isTopScorer) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isTopScorer ? Colors.amber[400] : Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$rank',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isTopScorer ? Colors.white : Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildPlayerCell(PlayerModel player) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green[100],
          child: Text(
            (player.name?.isNotEmpty == true) ? player.name![0].toUpperCase() : 'P',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          player.name ?? 'Unknown',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCell(PlayerModel player) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('seasons')
          .doc(widget.seasonModel.id)
          .collection('teams')
          .doc(player.teamId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('-', style: GoogleFonts.inter(fontSize: 14));
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            snapshot.data?['name'] ?? 'Unknown',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCell(int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value.toString(),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMobileStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Players Found',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
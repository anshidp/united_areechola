import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
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
  final teamsMapProvider = StateProvider<Map<String, String>>((ref) => {});

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  TextEditingController searchController = TextEditingController();

  Future<void> _fetchTeams() async {
    final teamsData = await ref
        .read(aslRepositoryProvider)
        .getTeams(widget.seasonModel.id ?? "");
    
    // Convert Map<String, dynamic> to Map<String, String> for just names
    // Structure of getTeams result: {'teamId': 'TeamName', ...}
    Map<String, String> names = {};
    teamsData.forEach((key, value) {
      names[key] = value.toString();
    });
    
    ref.read(teamsMapProvider.notifier).state = names;
  }

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
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
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Slightly darker for better card contrast
      body: Column(
        children: [
          // Header Section
          _buildHeader(size),
          
          // Players List/Table
          Expanded(
            child: _buildPlayersList(size, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        color: Colors.transparent, // Transparent to show scaffold color
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                   BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  ref.read(searchPlayers.notifier).state = value;
                },
                style: GoogleFonts.outfit(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search players...',
                  hintStyle: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.indigo[300]),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
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
            
            const SizedBox(height: 16),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Consumer(
                builder: (context, ref, _) {
                  final currentSort = ref.watch(sortBy);
                  return Row(
                    children: [
                      _buildFilterChip('Top Scorers', 'goals', currentSort),
                      const SizedBox(width: 10),
                      _buildFilterChip('Most Assists', 'assists', currentSort),
                      const SizedBox(width: 10),
                      _buildFilterChip('Name (A-Z)', 'name', currentSort),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentSort) {
    final isSelected = currentSort == value;
    return GestureDetector(
      onTap: () {
        ref.read(sortBy.notifier).state = value;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[200]!,
            width: 1 //No border if selected, handled by color
          ),
          boxShadow: isSelected 
            ? [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
            : null
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersList(Size size, bool isDesktop) {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(searchPlayers);
        ref.watch(sortBy);
        ref.watch(teamsMapProvider); // Rebuild when teams loaded
        
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
              return Center(child: CircularProgressIndicator(color: Colors.indigo[300]));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final players = _sortPlayers(snapshot.data!, ref.read(sortBy));

            // if (isDesktop) return _buildDesktopTable(players);

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final player = players[index];
                final isTop3 = index < 3 && ref.read(sortBy) != 'name';
                
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildPlayerCard(player, index + 1, isTop3),
                );
              },
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

  Widget _buildPlayerCard(PlayerModel player, int rank, bool isTop3) {
    final teamName = ref.read(teamsMapProvider)[player.teamId] ?? "Unknown Team";
    final goals = player.statics['goal'] ?? 0;
    final assists = player.statics['assist'] ?? 0;
    final yellow = player.statics['yelloCard'] ?? 0;
    final red = player.statics['redCard'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200), // Clean border
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // Subtler, crisper shadow
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Player Header
          Row(
            children: [
              // Rank Badge
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isTop3 ? Colors.amber[50] : Colors.grey[50],
                  shape: BoxShape.circle,
                  border: isTop3 ? Border.all(color: Colors.amber, width: 1.5) : null
                ),
                child: Text(
                  "#$rank",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isTop3 ? Colors.amber[800] : Colors.grey[500]
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Name & Team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name ?? "Player",
                      style: GoogleFonts.outfit(
                        fontSize: 18, // Slightly larger
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      teamName,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          
          // Stats Row (Restored Style)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Goals", goals.toString(), Icons.sports_soccer_rounded, Colors.green),
              _buildStatItem("Assists", assists.toString(), Icons.handshake_rounded, Colors.blue),
              _buildStatItem("Yellow", yellow.toString(), Icons.rectangle_rounded, Colors.amber[700]!),
              _buildStatItem("Red", red.toString(), Icons.rectangle_rounded, Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500
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
          Icon(Icons.person_off_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No players found',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}
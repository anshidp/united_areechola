import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class AddPlayers extends ConsumerStatefulWidget {
  const AddPlayers({super.key});

  @override
  ConsumerState<AddPlayers> createState() => _AddPlayersState();
}

class _AddPlayersState extends ConsumerState<AddPlayers>
    with TickerProviderStateMixin {
  final selectPossition = StateProvider<String?>((ref) => null);
  final selectPossitionShort = StateProvider<String?>((ref) => null);
  final selectTeam = StateProvider<String?>((ref) => null);
  final selectPlayerModel = StateProvider<PlayerModel?>((ref) => null);
  final searchPlayers = StateProvider<String>((ref) => "");
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});
  final selectSeason = StateProvider<String?>((ref) => null);
  final isPlayerEdit = StateProvider<bool>((ref) => false);
  final nameController = TextEditingController();
  final auctionPriceController = TextEditingController();
  final searchController = TextEditingController();

  String? downloadUrl;
  bool isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> possitoins = [
    "Center-Back (CB)",
    "Left-Back (LB)",
    "Right-Back (RB)",
    "Central Midfielder (CM)",
    "Center Forward (CF)",
    "Left Midfielder (LM)",
    "Right Winger (RW)",
    "Left Winger (LW)",
    "Goalkeeper",
  ];

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
    _animationController.forward();
    getSeasons();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> transferPlayersToSeason(String seasonId) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final playersSnapshot = await firestore.collection('players').get();
      for (var doc in playersSnapshot.docs) {
        final playerData = doc.data();
        await firestore
            .collection('seasons')
            .doc(seasonId)
            .collection('players')
            .doc(doc.id)
            .set(playerData);
      }
      print('✅ All players transferred to season/$seasonId/players');
    } catch (e) {
      print('❌ Error transferring players: $e');
    }
  }

  void getSeasons() async {
    ref.read(seasons.notifier).state =
        await ref.read(aslRepositoryProvider).getSeasons();
  }

  Future<String?> pickAndUploadFile(BuildContext context) async {
    setState(() => isUploading = true);
    String? imageUrl;
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (filePickerResult != null) {
      final platformFile = filePickerResult.files.single;
      final fileBytes = platformFile.bytes;

      final storageRef = FirebaseStorage.instance.ref();
      final uploadTask = storageRef
          .child(
              'players/${DateTime.now().millisecondsSinceEpoch}_${platformFile.name}')
          .putData(fileBytes!);

      await uploadTask;
      imageUrl = await storageRef
          .child(
              'players/${DateTime.now().millisecondsSinceEpoch}_${platformFile.name}')
          .getDownloadURL();
    }
    setState(() => isUploading = false);
    return imageUrl;
  }

  void _clearForm() {
    nameController.clear();
    auctionPriceController.clear();
    searchController.clear();
    ref.read(selectPossition.notifier).state = null;
    ref.read(selectTeam.notifier).state = null;
    ref.read(selectPlayerModel.notifier).state = null;
    ref.read(isPlayerEdit.notifier).state = false;
    downloadUrl = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1E293B),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Player Management',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(w * 0.02),
                child: Column(
                  children: [
                    // Player Form Card
                    _buildPlayerFormCard(w, h),
                    SizedBox(height: w * 0.03),

                    // Search and Filters
                    _buildSearchAndFilters(w),
                    SizedBox(height: w * 0.02),

                    // Players List
                    _buildPlayersDataTable(w, h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerFormCard(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.025),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.person_add, color: Colors.white, size: 24),
              ),
              SizedBox(width: w * 0.015),
              Text(
                ref.watch(isPlayerEdit) ? "Update Player" : "Add New Player",
                style: GoogleFonts.inter(
                  fontSize: w * 0.018,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (ref.watch(isPlayerEdit))
                TextButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                  label: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                  ),
                ),
            ],
          ),
          SizedBox(height: w * 0.025),

          // Player Image Upload Section
          Center(
            child: GestureDetector(
              onTap: () async {
                downloadUrl = await pickAndUploadFile(context);
                setState(() {});
              },
              child: Container(
                width: w * 0.12,
                height: w * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: downloadUrl != null
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF334155), Color(0xFF475569)],
                        ),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B981),
                          strokeWidth: 2,
                        ),
                      )
                    : downloadUrl != null
                        ? ClipOval(
                            child: Image.network(
                              downloadUrl!,
                              fit: BoxFit.cover,
                              width: w * 0.12,
                              height: w * 0.12,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt,
                                color: Color(0xFF64748B),
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Upload',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
          SizedBox(height: w * 0.025),

          // Form Fields Grid
          Row(
            children: [
              // Left Column
              Expanded(
                child: Column(
                  children: [
                    _buildModernDropdown(
                      context,
                      label: "Season",
                      hint: "Select Season",
                      value: ref.watch(selectSeason),
                      items: ref
                          .watch(seasons)
                          .entries
                          .map((season) => DropdownMenuItem(
                              value: season.key, child: Text(season.value)))
                          .toList(),
                      onChanged: (value) async {
                        ref.read(selectSeason.notifier).state = value;
                        ref.read(teams.notifier).state = await ref
                            .read(aslRepositoryProvider)
                            .getTeams(value ?? "");
                      },
                      w: w,
                    ),
                    SizedBox(height: w * 0.02),
                    _buildModernTextField(
                      nameController,
                      "Player Name",
                      "Enter player name",
                      Icons.person,
                      w,
                    ),
                    SizedBox(height: w * 0.02),
                    _buildModernTextField(
                      auctionPriceController,
                      "Auction Price",
                      "Enter auction price",
                      Icons.attach_money,
                      w,
                      isNumber: true,
                    ),
                  ],
                ),
              ),
              SizedBox(width: w * 0.03),
              // Right Column
              Expanded(
                child: Column(
                  children: [
                    _buildModernDropdown(
                      context,
                      label: "Position",
                      hint: "Select Position",
                      value: ref.watch(selectPossition),
                      items: possitoins
                          .map((pos) =>
                              DropdownMenuItem(value: pos, child: Text(pos)))
                          .toList(),
                      onChanged: (value) {
                        ref.read(selectPossition.notifier).state = value;
                        if ((value ?? "").contains("()")) {
                          String? shortForm =
                              (value ?? "").split('(')[1].replaceAll(')', '');
                          ref.read(selectPossitionShort.notifier).state =
                              shortForm;
                        }
                      },
                      w: w,
                    ),
                    SizedBox(height: w * 0.02),
                    _buildModernDropdown(
                      context,
                      label: "Team",
                      hint: "Select Team",
                      value: ref.watch(selectTeam),
                      items: ref
                          .watch(teams)
                          .entries
                          .map((team) => DropdownMenuItem(
                              value: team.key, child: Text(team.value)))
                          .toList(),
                      onChanged: (value) {
                        ref.read(selectTeam.notifier).state = value;
                      },
                      w: w,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.03),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  return showSnackBarToast(context, "Please enter name", "red");
                } else if ((ref.read(selectPossition) ?? "").isEmpty) {
                  return showSnackBarToast(
                      context, "Please choose position", "red");
                }

                if (ref.read(isPlayerEdit)) {
                  final confirm = await alert(
                      context, "Do you want to update this player?", w, h);
                  if (confirm) {
                    final copy = ref.read(selectPlayerModel)?.copyWith(
                        price: double.parse(auctionPriceController.text.trim()),
                        search: setSearchParam(nameController.text.trim()),
                        name: nameController.text.trim(),
                        image: downloadUrl,
                        possition: ref.read(selectPossition),
                        possitionShort: ref.read(selectPossitionShort),
                        teamId: ref.read(selectTeam));
                    ref.read(aslRepositoryProvider).updatePlayer(
                        ref.read(selectPlayerModel)?.playerId ?? "",
                        copy!,
                        ref.read(selectSeason) ?? "");

                    if (context.mounted) {
                      showSnackBarToast(
                          context,
                          "${nameController.text.trim()} updated successfully",
                          "green");
                    }
                    _clearForm();
                  }
                } else {
                  final confirm = await alert(
                      context, "Do you want to add this player?", w, h);
                  if (confirm) {
                    final playerModel = PlayerModel(
                        appearences: 0,
                        price: double.parse(auctionPriceController.text.trim()),
                        possitionShort: ref.read(selectPossitionShort) ?? "",
                        teamId: ref.read(selectTeam) ?? "",
                        name: nameController.text.trim(),
                        image: downloadUrl ?? "",
                        possition: ref.read(selectPossition) ?? "",
                        delete: false,
                        search: setSearchParam(nameController.text.trim()),
                        createdDate: DateTime.now(),
                        statics: {
                          "goal": 0,
                          "assist": 0,
                          "yelloCard": 0,
                          "redCard": 0,
                          "bestPlayer": 0,
                          "bestGoal": 0
                        });
                    ref.read(aslRepositoryProvider).addNewPlayer(
                        playerModel, ref.read(selectSeason) ?? "");
                    showSnackBarToast(
                        context,
                        "${nameController.text.trim()} added successfully",
                        "green");
                    _clearForm();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ref.watch(isPlayerEdit) ? Icons.update : Icons.add,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    ref.watch(isPlayerEdit) ? "Update Player" : "Add Player",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

  Widget _buildSearchAndFilters(double w) {
    return Container(
      padding: EdgeInsets.all(w * 0.02),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                ref.read(searchPlayers.notifier).state = value;
              },
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search players...',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF10B981)),
                ),
                filled: true,
                fillColor: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersDataTable(double w, double h) {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(searchPlayers);
        return StreamBuilder<List<PlayerModel>>(
          stream: FirebaseFirestore.instance
              .collection("seasons")
              .doc(ref.read(selectSeason))
              .collection('players')
              .where('delete', isEqualTo: false)
              .where('search',
                  arrayContains: ref.read(searchPlayers).isEmpty
                      ? null
                      : ref.read(searchPlayers).toUpperCase())
              .snapshots()
              .map((event) => event.docs
                  .map((e) => PlayerModel.fromMap(e.data()))
                  .toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 48,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No players found',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final players = snapshot.data!;

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DataTable(
                  columnSpacing: 40,
                  horizontalMargin: 24,
                  dataRowMinHeight: 72,
                  dataRowMaxHeight: 72,
                  headingRowHeight: 60,
                  headingTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  dataTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: const Color(0xFFE2E8F0),
                  ),
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFF0F172A)),
                  columns: const [
                    DataColumn(label: Text("No.")),
                    DataColumn(label: Text("Photo")),
                    DataColumn(label: Text("Player Name")),
                    DataColumn(label: Text("Position")),
                    DataColumn(label: Text("Team")),
                    DataColumn(label: Text("Price")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: List.generate(
                    players.length,
                    (index) {
                      final player = players[index];
                      final isEven = index.isEven;
                      return DataRow(
                        color: WidgetStateProperty.all(
                          isEven
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF1E293B),
                        ),
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(
                            player.image.isNotEmpty
                                ? Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF10B981),
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(player.image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF334155),
                                      border: Border.all(
                                        color: const Color(0xFF64748B),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF94A3B8),
                                      size: 24,
                                    ),
                                  ),
                          ),
                          DataCell(Text(player.name)),
                          DataCell(Text(player.possition)),
                          DataCell(Text(ref.read(teams)[player.teamId] ?? "")),
                          DataCell(Text('₹${player.price.toStringAsFixed(0)}')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    ref.read(isPlayerEdit.notifier).state =
                                        true;
                                    ref.read(selectPlayerModel.notifier).state =
                                        player;
                                    downloadUrl = player.image;
                                    auctionPriceController.text =
                                        player.price.toString();
                                    nameController.text = player.name;
                                    ref.read(selectPossition.notifier).state =
                                        player.possition;
                                    ref.read(selectTeam.notifier).state =
                                        player.teamId;
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF3B82F6),
                                    size: 20,
                                  ),
                                  tooltip: 'Edit Player',
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final confirm = await alert(
                                        context,
                                        "Do you want to delete this player?",
                                        w,
                                        h);
                                    if (confirm) {
                                      // Add delete functionality here
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  tooltip: 'Delete Player',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    double w, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown(
    BuildContext context, {
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required double w,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                hint,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              value: value,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item.value,
                  child: Text(
                    item.child
                        .toString()
                        .replaceAll('Text("', '')
                        .replaceAll('")', ''),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              dropdownColor: const Color(0xFF1E293B),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

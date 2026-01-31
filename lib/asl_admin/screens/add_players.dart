import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.02),
          child: Column(
            children: [
              // Header
              _buildHeaderSection(w),
              SizedBox(height: w * 0.03),

              // Form
              _buildPlayerFormCard(w, h),
              SizedBox(height: w * 0.03),

              // Search
              _buildSearchBar(w),
              SizedBox(height: w * 0.02),

              // Table
              _buildPlayersTable(w, h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double w) {
    return Container(
      padding: EdgeInsets.all(w * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          ref.read(searchPlayers.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: "Search players...",
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
              Icons.people_alt,
              color: Colors.white,
              size: w * 0.03,
            ),
          ),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Player Management',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Add and manage players efficiently',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.012,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerFormCard(double w, double h) {
    return Container(
      width: double.infinity,
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
          // Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.01),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(w * 0.008),
                ),
                child: Icon(
                  ref.watch(isPlayerEdit) ? Icons.edit : Icons.add,
                  color: const Color(0xFF4F46E5),
                  size: w * 0.02,
                ),
              ),
              SizedBox(width: w * 0.015),
              Text(
                ref.watch(isPlayerEdit) ? "Update Player" : "Add New Player",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.02,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.03),

          // Upload
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
                      : LinearGradient(
                          colors: [
                            const Color(0xFF4F46E5).withOpacity(0.1),
                            const Color(0xFF7C3AED).withOpacity(0.1),
                          ],
                        ),
                  border: Border.all(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: downloadUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(w * 0.06),
                        child: Image.network(downloadUrl!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: w * 0.035, color: const Color(0xFF4F46E5)),
                          SizedBox(height: w * 0.005),
                          Text(
                            'Upload Photo',
                            style: GoogleFonts.poppins(
                              fontSize: w * 0.01,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          SizedBox(height: w * 0.04),

          // Fields
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildModernDropdownField(
                      label: "Season",
                      icon: Icons.calendar_today,
                      value: ref.watch(selectSeason),
                      items: ref.watch(seasons).entries.map((s) {
                        return DropdownMenuItem<String>(
                            value: s.key, child: Text(s.value));
                      }).toList(),
                      onChanged: (value) async {
                        ref.read(selectSeason.notifier).state = value;
                        ref.read(teams.notifier).state = await ref
                            .read(aslRepositoryProvider)
                            .getTeams(value ?? "");
                      },
                    ),
                    SizedBox(height: w * 0.02),
                    _buildModernTextField(
                      label: "Player Name",
                      hint: "Enter player name",
                      icon: Icons.person,
                      controller: nameController,
                    ),
                    SizedBox(height: w * 0.02),
                    _buildModernTextField(
                      label: "Auction Price",
                      hint: "Enter price",
                      icon: Icons.attach_money,
                      controller: auctionPriceController,
                    ),
                  ],
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Column(
                  children: [
                    _buildModernDropdownField(
                      label: "Position",
                      icon: Icons.sports_soccer,
                      value: ref.watch(selectPossition),
                      items: possitoins
                          .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (value) {
                        ref.read(selectPossition.notifier).state = value;
                        if ((value ?? "").contains("(")) {
                          ref.read(selectPossitionShort.notifier).state =
                              value!.split('(')[1].replaceAll(')', '');
                        }
                      },
                    ),
                    SizedBox(height: w * 0.02),
                    _buildModernDropdownField(
                      label: "Team",
                      icon: Icons.groups,
                      value: ref.watch(selectTeam),
                      items: ref.watch(teams).entries.map((t) {
                        return DropdownMenuItem<String>(
                            value: t.key, child: Text(t.value));
                      }).toList(),
                      onChanged: (value) {
                        ref.read(selectTeam.notifier).state = value;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.04),

          // Button
          SizedBox(
            width: double.infinity,
            height: w * 0.04,
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
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.015),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ref.watch(isPlayerEdit) ? Icons.update : Icons.add),
                  SizedBox(width: w * 0.01),
                  Text(
                    ref.watch(isPlayerEdit) ? "Update Player" : "Add Player",
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

  Widget _buildModernTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
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
            controller: controller,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E293B),
              fontSize: MediaQuery.of(context).size.width * 0.011,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: MediaQuery.of(context).size.width * 0.011,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF4F46E5),
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
                    const BorderSide(color: Color(0xFF4F46E5), width: 2),
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
                color: const Color(0xFF4F46E5),
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

  Widget _buildPlayersTable(double w, double h) {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(searchPlayers);

        return StreamBuilder<List<PlayerModel>>(
          stream: FirebaseFirestore.instance
              .collection("seasons")
              .doc(ref.read(selectSeason))
              .collection('players')
              .where('delete', isEqualTo: false)
              .where(
                'search',
                arrayContains: ref.read(searchPlayers).isEmpty
                    ? null
                    : ref.read(searchPlayers).toUpperCase(),
              )
              .snapshots()
              .map((event) => event.docs
                  .map((e) => PlayerModel.fromMap(e.data()))
                  .toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Color(0xFF4F46E5),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(w * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: w * 0.08,
                      color: const Color(0xFF9CA3AF),
                    ),
                    SizedBox(height: w * 0.02),
                    Text(
                      'No Players Found',
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.018,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: w * 0.01),
                    Text(
                      'Start by adding your first player',
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.012,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            }

            final players = snapshot.data!;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(w * 0.02),
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
                  // Table Header
                  Container(
                    padding: EdgeInsets.all(w * 0.02),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(w * 0.02),
                        topRight: Radius.circular(w * 0.02),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.table_chart, color: Colors.white),
                        SizedBox(width: w * 0.01),
                        Text(
                          "Players Overview",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: w * 0.016,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data Table
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(w * 0.02),
                      bottomRight: Radius.circular(w * 0.02),
                    ),
                    child: DataTable(
                      dataRowMinHeight: 70,
                      dataRowMaxHeight: 80,
                      dividerThickness: 0,
                      headingTextStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: w * 0.012,
                        color: Colors.white,
                      ),
                      dataTextStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: w * 0.011,
                        color: const Color(0xFF374151),
                      ),
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFF6366F1),
                      ),
                      columns: const [
                        DataColumn(label: Text("Sl No")),
                        DataColumn(label: Text("Photo")),
                        DataColumn(label: Text("Player Name")),
                        DataColumn(label: Text("Position")),
                        DataColumn(label: Text("Team")),
                        DataColumn(label: Text("Price")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: List.generate(players.length, (index) {
                        final player = players[index];

                        return DataRow(
                          color: WidgetStateProperty.all(
                            index.isEven
                                ? const Color(0xFFF8FAFC)
                                : Colors.white,
                          ),
                          cells: [
                            // Sl No
                            DataCell(Text('${index + 1}')),

                            // Photo
                            DataCell(
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF4F46E5)
                                        .withOpacity(0.3),
                                    width: 2,
                                  ),
                                  image: player.image.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(player.image),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: player.image.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color: const Color(0xFF4F46E5)
                                            .withOpacity(0.5),
                                        size: w * 0.02,
                                      )
                                    : null,
                              ),
                            ),

                            // Name
                            DataCell(Text(
                              player.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            )),

                            // Position
                            DataCell(Text(player.possition)),

                            // Team
                            DataCell(
                                Text(ref.read(teams)[player.teamId] ?? "-")),

                            // Price
                            DataCell(
                                Text("₹${player.price.toStringAsFixed(0)}")),

                            // Actions
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildActionButton(
                                    icon: Icons.edit,
                                    color: Colors.blue,
                                    onTap: () {
                                      ref.read(isPlayerEdit.notifier).state =
                                          true;
                                      ref
                                          .read(selectPlayerModel.notifier)
                                          .state = player;
                                      downloadUrl = player.image;
                                      auctionPriceController.text =
                                          player.price.toString();
                                      nameController.text = player.name;
                                      ref.read(selectPossition.notifier).state =
                                          player.possition;
                                      ref.read(selectTeam.notifier).state =
                                          player.teamId;
                                    },
                                  ),
                                  SizedBox(width: w * 0.005),
                                  _buildActionButton(
                                    icon: Icons.delete,
                                    color: Colors.red,
                                    onTap: () async {
                                      final confirm = await alert(
                                        context,
                                        "Do you want to delete this player?",
                                        w,
                                        h,
                                      );
                                      if (confirm) {
                                        // 🔴 Add delete logic here
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/manager_model.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/team_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/utils/constants.dart';

class AddTeams extends ConsumerStatefulWidget {
  const AddTeams({super.key});

  @override
  ConsumerState<AddTeams> createState() => _AddPlayersState();
}

class _AddPlayersState extends ConsumerState<AddTeams>
    with TickerProviderStateMixin {
  final selectmanager = StateProvider<String?>((ref) => null);
  final selectTeam = StateProvider<String?>((ref) => null);
  final isTeamEdit = StateProvider<bool>((ref) => false);
  final selectSeason = StateProvider<String?>((ref) => null);
  final selectGroup = StateProvider<String?>((ref) => null);
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});
  final managers = StateProvider<Map<String, ManagerModel>>((ref) => {});
  final selectedPlayers = [];
  final teamPlayers = StateProvider<Map<String, PlayerModel>>((ref) => {});
  final selectedTeamModel = StateProvider<AslTeamModel?>((ref) => null);
  final teamNameController = TextEditingController();
  final groups = ["A", "B"];
  String? downloadUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
    getSeasons();
    getPlayers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String?> pickAndUploadFile(BuildContext context) async {
    String? imageUrl;
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (filePickerResult != null) {
      final platformFile = filePickerResult.files.single;
      final fileBytes = platformFile.bytes;

      final storageRef = FirebaseStorage.instance.ref();
      final uploadTask =
          storageRef.child('teams/${platformFile.name}').putData(fileBytes!);

      await uploadTask;
      imageUrl =
          await storageRef.child('teams/${platformFile.name}').getDownloadURL();

      return imageUrl;
    }
    return null;
  }

  void getPlayers() async {
    ref.read(teamPlayers.notifier).state =
        await ref.read(aslRepositoryProvider).getPlayers();
  }

  void getSeasons() async {
    ref.read(seasons.notifier).state =
        await ref.read(aslRepositoryProvider).getSeasons();
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
              // Header Section
              _buildHeaderSection(w),
              SizedBox(height: w * 0.03),

              // Main Form Card
              _buildFormCard(w, h),
              SizedBox(height: w * 0.03),

              // Teams Data Table
              _buildTeamsTable(w),
            ],
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
              Icons.groups,
              color: Colors.white,
              size: w * 0.03,
            ),
          ),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Management',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Add and manage your teams efficiently',
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

  Widget _buildFormCard(double w, double h) {
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
          // Form Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.01),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(w * 0.008),
                ),
                child: Icon(
                  ref.watch(isTeamEdit) ? Icons.edit : Icons.add,
                  color: const Color(0xFF4F46E5),
                  size: w * 0.02,
                ),
              ),
              SizedBox(width: w * 0.015),
              Text(
                ref.watch(isTeamEdit) ? "Update Team" : "Add New Team",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.02,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.03),

          // Team Logo Upload Section
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
                        child: Image.network(
                          downloadUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: w * 0.035,
                            color: const Color(0xFF4F46E5),
                          ),
                          SizedBox(height: w * 0.005),
                          Text(
                            'Upload Logo',
                            style: GoogleFonts.poppins(
                              fontSize: w * 0.01,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: w * 0.04),

          // Form Fields Row
          Row(
            children: [
              // Season Dropdown
              Expanded(
                child: _buildModernDropdownField(
                  label: "Season",
                  icon: Icons.calendar_today,
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
                    if (value != null) {
                      ref.read(selectSeason.notifier).state = value;
                      ref.read(managers.notifier).state = await ref
                          .read(aslRepositoryProvider)
                          .getManagers(season: value);
                    }
                  },
                ),
              ),
              SizedBox(width: w * 0.02),

              // Team Name Field
              Expanded(
                child: _buildModernTextField(
                  label: "Team Name",
                  hint: "Enter team name",
                  icon: Icons.shield,
                  controller: teamNameController,
                ),
              ),
              SizedBox(width: w * 0.02),

              // Manager Dropdown
              Expanded(
                child: _buildModernDropdownField(
                  label: "Manager",
                  icon: Icons.person,
                  value: (ref.watch(selectmanager) ?? "").isEmpty
                      ? null
                      : ref.read(selectmanager),
                  items: ref.watch(managers).entries.map((pos) {
                    return DropdownMenuItem<String>(
                      value: pos.key,
                      child: Text(
                        pos.value.managerName,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E293B),
                          fontSize: w * 0.011,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(selectmanager.notifier).state = value;
                  },
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: _buildModernDropdownField(
                  label: "Group",
                  icon: Icons.calendar_today,
                  value: (ref.watch(selectGroup) ?? "").isEmpty
                      ? null
                      : ref.read(selectGroup),
                  items: groups.map((g) {
                    return DropdownMenuItem<String>(
                      value: g,
                      child: Text(
                        g,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E293B),
                          fontSize: w * 0.011,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      ref.read(selectGroup.notifier).state = value;
                    }
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.04),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: w * 0.04,
            child: ElevatedButton(
              onPressed: () async {
                await _handleTeamSubmission(context, w, h);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
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
                    ref.watch(isTeamEdit) ? Icons.update : Icons.add_circle,
                    size: w * 0.015,
                  ),
                  SizedBox(width: w * 0.01),
                  Text(
                    ref.watch(isTeamEdit) ? "Update Team" : "Add Team",
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

  Widget _buildTeamsTable(double w) {
    return Consumer(
      builder: (context, ref, _) {
        return StreamBuilder<List<AslTeamModel>>(
          stream: FirebaseFirestore.instance
              .collection(FirebaseConstants.seasonCollection)
              .doc(ref.read(selectSeason))
              .collection('teams')
              .where('delete', isEqualTo: false)
              .snapshots()
              .map((event) => event.docs
                  .map((e) => AslTeamModel.fromMap(e.data()))
                  .toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(w);
            }

            final teams = snapshot.data!;

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
                        Icon(Icons.table_chart,
                            color: Colors.white, size: w * 0.02),
                        SizedBox(width: w * 0.01),
                        Text(
                          'Teams Overview',
                          style: GoogleFonts.poppins(
                            fontSize: w * 0.016,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Content
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
                        DataColumn(label: Text("Logo")),
                        DataColumn(label: Text("Team Name")),
                        DataColumn(label: Text("Manager")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: List.generate(
                        teams.length,
                        (index) {
                          final team = teams[index];
                          return DataRow(
                            color: WidgetStateProperty.all(
                              index.isEven
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white,
                            ),
                            cells: [
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.008,
                                    vertical: w * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F46E5)
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(w * 0.005),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              ),
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
                                    image: team.image.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(team.image),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: team.image.isEmpty
                                      ? Icon(
                                          Icons.shield,
                                          color: const Color(0xFF4F46E5)
                                              .withOpacity(0.5),
                                          size: w * 0.02,
                                        )
                                      : null,
                                ),
                              ),
                              DataCell(
                                Text(
                                  team.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection(
                                          FirebaseConstants.seasonCollection)
                                      .doc(ref.read(selectSeason))
                                      .collection("managers")
                                      .doc(team.manager)
                                      .get(),
                                  builder: (context, asyncSnapshot) {
                                    if (!asyncSnapshot.hasData ||
                                        !asyncSnapshot.data!.exists) {
                                      return const Text("-");
                                    }
                                    final data =
                                        asyncSnapshot.data!.data() ?? {};
                                    final name =
                                        data['managerName'] as String? ?? "-";
                                    return Text(name);
                                  },
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildActionButton(
                                      icon: Icons.edit,
                                      color: Colors.blue,
                                      onTap: () => _editTeam(team, ref),
                                    ),
                                    SizedBox(width: w * 0.005),
                                    _buildActionButton(
                                      icon: Icons.delete,
                                      color: Colors.red,
                                      onTap: () async {
                                        // Handle delete
                                      },
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

  Widget _buildEmptyState(double w) {
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
            Icons.groups_outlined,
            size: w * 0.08,
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: w * 0.02),
          Text(
            'No Teams Found',
            style: GoogleFonts.poppins(
              fontSize: w * 0.018,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: w * 0.01),
          Text(
            'Start by adding your first team',
            style: GoogleFonts.poppins(
              fontSize: w * 0.012,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  void _editTeam(AslTeamModel team, WidgetRef ref) {
    ref.read(isTeamEdit.notifier).state = true;
    ref.read(selectedTeamModel.notifier).state = team;
    downloadUrl = team.image;
    teamNameController.text = team.name;
    ref.read(selectTeam.notifier).state = team.teamId;
    ref.read(selectmanager.notifier).state = team.manager;
    ref.read(selectGroup.notifier).state = team.group;
  }

  Future<void> _handleTeamSubmission(
      BuildContext context, double w, double h) async {
    if (teamNameController.text.trim().isEmpty) {
      return showSnackBarToast(context, "Please enter team name", "red");
    } else if ((ref.read(selectmanager) ?? "").isEmpty) {
      return showSnackBarToast(context, "Please choose manager", "red");
    } else if ((ref.read(selectGroup) ?? "").isEmpty) {
      return showSnackBarToast(context, "Please choose group", "red");
    }

    if (ref.read(isTeamEdit)) {
      final confirm =
          await alert(context, "Do you want to update this team?", w, h);
      if (confirm) {
        final copy = ref.read(selectedTeamModel)?.copyWith(
            name: teamNameController.text,
            manager: ref.read(selectmanager),
            image: downloadUrl,
            group: ref.read(selectGroup));

        ref.read(aslRepositoryProvider).updateTeam(
              ref.read(selectedTeamModel)?.teamId ?? "",
              copy!,
              ref.read(selectSeason) ?? "",
            );

        showSnackBarToast(context, "Team updated successfully", "green");
        _resetForm();
      }
    } else {
      final confirm =
          await alert(context, "Do you want to add this team?", w, h);
      if (confirm) {
        final teamModel = AslTeamModel(
          seasonId: ref.read(selectSeason) ?? '',
          group: ref.read(selectGroup) ?? "",
          draw: 0,
          playedMatch: 0,
          win: 0,
          lose: 0,
          point: 0,
          name: teamNameController.text.trim(),
          image: downloadUrl ?? "",
          manager: ref.read(selectmanager) ?? "",
          delete: false,
          search: setSearchParam(teamNameController.text.trim()),
          players: [],
          goalsAgainst: 0,
          goalsFor: 0
        );
        final teamId = await ref
            .read(aslRepositoryProvider)
            .addAslTeam(teamModel, ref.read(selectSeason) ?? "");

        for (var player in selectedPlayers) {
          await FirebaseFirestore.instance
              .collection(FirebaseConstants.seasonCollection)
              .doc(ref.read(selectSeason))
              .collection(FirebaseConstants.playerCollection)
              .doc(player)
              .update({"teamId": teamId});
        }

        await db
            .collection(FirebaseConstants.seasonCollection)
            .doc(ref.read(selectSeason))
            .update({"teams": FieldValue.increment(1)});

        showSnackBarToast(context, "New team added successfully", "green");
        _resetForm();
      }
    }
  }

  void _resetForm() {
    teamNameController.clear();
    selectedPlayers.clear();
    ref.read(selectmanager.notifier).state = null;
    ref.read(isTeamEdit.notifier).state = false;
    downloadUrl = null;
    setState(() {});
  }

  void _togglePlayerSelection(String playerId) {
    setState(() {
      if (selectedPlayers.contains(playerId)) {
        selectedPlayers.remove(playerId);
      } else {
        selectedPlayers.add(playerId);
      }
    });
  }

  void _removePlayer(String playerId) {
    setState(() {
      selectedPlayers.remove(playerId);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/manager_model.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class AddManager extends ConsumerStatefulWidget {
  const AddManager({super.key});

  @override
  ConsumerState<AddManager> createState() => _AddManagerState();
}

class _AddManagerState extends ConsumerState<AddManager>
    with TickerProviderStateMixin {
  final managernameController = TextEditingController();
  final yearController = TextEditingController();
  final endDateController = TextEditingController();
  final teamPlayers = StateProvider<Map<String, PlayerModel>>((ref) => {});
  final selectedPlayers = [];
  final selectSeason = StateProvider<String?>((ref) => null);
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});

  final endDate = StateProvider<DateTime?>((ref) => null);
  final selectedTeam = StateProvider<String?>((ref) => null);
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);

    getSeasons();
    getPlayers();
    getTeams();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void getTeams() async {
    ref.read(teams.notifier).state =
        await ref.read(aslRepositoryProvider).getAllTeams();
  }

  void getPlayers() async {
    ref.read(teamPlayers.notifier).state =
        await ref.read(aslRepositoryProvider).getPlayers();
  }

  void getSeasons() async {
    ref.read(seasons.notifier).state =
        await ref.read(aslRepositoryProvider).getSeasons();
  }

  void _clearForm() {
    managernameController.clear();
    ref.read(selectSeason.notifier).state = null;
    selectedPlayers.clear();
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
              // Header Section (same as AddTeams)
              _buildHeaderSection(w),
              SizedBox(height: w * 0.03),

              // Main Form Card
              _buildFormCard(w, h),
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
              Icons.person_add,
              color: Colors.white,
              size: w * 0.03,
            ),
          ),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manager Management',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Add and manage managers efficiently',
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
                  Icons.person_add,
                  color: const Color(0xFF4F46E5),
                  size: w * 0.02,
                ),
              ),
              SizedBox(width: w * 0.015),
              Text(
                "Add New Manager",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.02,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.03),

          // Fields Row
          Row(
            children: [
              // Season
              Expanded(
                child: _buildModernDropdownField(
                  label: "Season",
                  icon: Icons.calendar_today,
                  value: ref.watch(selectSeason),
                  items: ref.watch(seasons).entries.map((pos) {
                    return DropdownMenuItem<String>(
                      value: pos.key,
                      child: Text(pos.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(selectSeason.notifier).state = value;
                  },
                ),
              ),
              SizedBox(width: w * 0.02),

              // Manager Name
              Expanded(
                child: _buildModernTextField(
                  label: "Manager Name",
                  hint: "Enter manager name",
                  icon: Icons.person,
                  controller: managernameController,
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
                if (managernameController.text.trim().isEmpty) {
                  return showSnackBarToast(context, "Please enter name", "red");
                }

                final confirm = await alert(
                    context, "Do you want to add this manager?", w, h);

                if (confirm) {
                  final managerModel = ManagerModel(
                    managerName: managernameController.text.trim(),
                    createdDate: DateTime.now(),
                    delete: false,
                    seasonName: ref.read(selectSeason) ?? "",
                  );

                  ref.read(aslRepositoryProvider).addNewManager(
                        managerModel,
                        ref.read(selectSeason) ?? "",
                      );

                  showSnackBarToast(
                      context, "Manager added successfully", "green");
                  _clearForm();
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
                  Icon(Icons.add_circle, size: w * 0.015),
                  SizedBox(width: w * 0.01),
                  Text(
                    "Add Manager",
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
}

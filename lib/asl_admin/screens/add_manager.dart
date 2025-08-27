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
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF0A0E27),
              Color(0xFF000000),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.02),
              child: Column(
                children: [
                  // Animated Header

                  SizedBox(height: w * 0.03),

                  // Main Card
                  _buildMainCard(w, h),

                  SizedBox(height: w * 0.02),

                  // Stats Cards
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(double w, double h) {
    return Container(
      width: w * 0.5,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(-10, -10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Animation
          Row(
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Manager',
                      style: GoogleFonts.inter(
                        fontSize: w * 0.020,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Create a new team manager profile',
                      style: GoogleFonts.inter(
                        fontSize: w * 0.011,
                        color: const Color(0xFF718096),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.025),

          // Animated Divider
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            builder: (context, double value, child) {
              return Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    stops: [0, value, value, 1],
                    colors: const [
                      Color(0xFF4ECDC4),
                      Color(0xFF4ECDC4),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: w * 0.025),

          // Form Fields
          _buildEnhancedDropdown(
            label: "Select Season",
            hint: "Choose a season",
            value: ref.watch(selectSeason),
            items: ref.watch(seasons).entries.map((season) {
              return DropdownMenuItem<String>(
                value: season.key,
                child: Text(season.value),
              );
            }).toList(),
            onChanged: (value) {
              ref.read(selectSeason.notifier).state = value;
            },
            w: w,
            icon: Icons.calendar_month,
            gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          ),

          SizedBox(height: w * 0.02),

          _buildEnhancedTextField(
            controller: managernameController,
            label: "Manager Name",
            hint: "Enter manager's full name",
            icon: Icons.person,
            w: w,
            gradientColors: [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
          ),

          SizedBox(height: w * 0.03),

          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSecondaryButton(
                'Clear Form',
                Icons.refresh,
                onPressed: _clearForm,
                w: w,
              ),
              SizedBox(width: w * 0.01),
              _buildPrimaryButton(w, h),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, double w) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            padding: EdgeInsets.all(w * 0.02),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                SizedBox(height: 12),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required double w,
    required List<Color> gradientColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: w * 0.012,
            color: const Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: w * 0.008),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: gradientColors.map((c) => c.withOpacity(0.1)).toList(),
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: w * 0.012,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3748),
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFFA0AEC0),
                fontSize: w * 0.011,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: gradientColors.first.withOpacity(0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: gradientColors.first,
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required double w,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: w * 0.012,
            color: const Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: w * 0.008),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: gradientColors.map((c) => c.withOpacity(0.1)).toList(),
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: gradientColors.first.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(
                        hint,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA0AEC0),
                          fontSize: w * 0.011,
                        ),
                      ),
                      value: value?.isEmpty == true ? null : value,
                      items: items.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.value,
                          child: Text(
                            item.child
                                .toString()
                                .replaceAll('Text("', '')
                                .replaceAll('")', ''),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF2D3748),
                              fontSize: w * 0.011,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                      dropdownColor: Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: gradientColors.first,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(double w, double h) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFE66D),
                  Color(0xFF4ECDC4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Add Manager",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: w * 0.014,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon, {
    required VoidCallback onPressed,
    required double w,
  }) {
    return SizedBox(
      height: 60,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFF4ECDC4),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF4ECDC4),
              size: 20,
            ),
            SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.inter(
                color: const Color(0xFF4ECDC4),
                fontWeight: FontWeight.w600,
                fontSize: w * 0.012,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

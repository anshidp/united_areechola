import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class AddSeason extends ConsumerStatefulWidget {
  const AddSeason({super.key});

  @override
  ConsumerState<AddSeason> createState() => _AddSeasonState();
}

class _AddSeasonState extends ConsumerState<AddSeason>
    with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final endDateController = TextEditingController();

  final endDate = StateProvider<DateTime?>((ref) => null);
  final selectedTeams = [];
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _cardAnimationController.forward();

    getTeams();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void getTeams() async {
    ref.read(teams.notifier).state =
        await ref.read(aslRepositoryProvider).getAllTeams();
  }

  void _clearForm() {
    nameController.clear();
    yearController.clear();
    endDateController.clear();
    ref.read(endDate.notifier).state = null;
    selectedTeams.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0F23),
                Color(0xFF1A1A3A),
                Color(0xFF0F0F23),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.02),
              child: Container(
                width: w * 0.5,
                constraints: BoxConstraints(
                  maxWidth: 600,
                  minWidth: 400,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section

                    SizedBox(height: w * 0.03),

                    // Main Form Card
                    _buildMainCard(w, h),

                    SizedBox(height: w * 0.02),

                    // Quick Stats Card (optional)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: w * 0.015),
              Text(
                'Add New Season',
                style: GoogleFonts.inter(
                  fontSize: w * 0.018,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.025),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF6366F1).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(height: w * 0.025),

          // Form Fields
          _buildStyledTextField(
            controller: nameController,
            label: "Season Name",
            hint: "Enter season name",
            icon: Icons.sports_soccer,
            w: w,
          ),
          SizedBox(height: w * 0.02),

          Row(
            children: [
              Expanded(
                child: _buildStyledTextField(
                  controller: yearController,
                  label: "Year",
                  hint: "2024",
                  icon: Icons.calendar_today,
                  w: w,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: _buildDateField(w),
              ),
            ],
          ),

          SizedBox(height: w * 0.03),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  'Clear Form',
                  Icons.clear_all,
                  onPressed: _clearForm,
                  w: w,
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                flex: 2,
                child: _buildPrimaryButton(w, h),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required double w,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: w * 0.012,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: w * 0.006),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.inter(
              fontSize: w * 0.011,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontSize: w * 0.010,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "End Date",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: w * 0.012,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: w * 0.006),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2400),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF6366F1),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF111827),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              ref.read(endDate.notifier).state = selectedDate;
              endDateController.text =
                  DateFormat("dd MMM yyyy").format(selectedDate);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AbsorbPointer(
              child: TextFormField(
                controller: endDateController,
                style: GoogleFonts.inter(
                  fontSize: w * 0.011,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  hintText: "Select end date",
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.event, size: 16, color: Colors.white),
                  ),
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF6B7280),
                  ),
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontSize: w * 0.010,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(double w, double h) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFFEC4899),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (nameController.text.trim().isEmpty) {
            return showSnackBarToast(context, "Please enter name", "red");
          } else if (yearController.text.isEmpty) {
            return showSnackBarToast(context, "Please enter year", "red");
          } else if (endDateController.text.isEmpty) {
            return showSnackBarToast(context, "Please select end date", "red");
          }

          final confirm =
              await alert(context, "Do you want to add season?", w, h);
          if (confirm) {
            final seasonModel = SeasonModel(
              bestPlayer: "",
              runner: "",
              teams: selectedTeams,
              winner: "",
              endDate: ref.read(endDate)!,
              seasonName: nameController.text.trim(),
              delete: false,
              search: setSearchParam(nameController.text.trim()),
              createdDate: DateTime.now(),
              year: int.parse(yearController.text.trim()),
            );
            ref.read(aslRepositoryProvider).addNewSeason(seasonModel);
            showSnackBarToast(context, "Season added successfully", "green");
            _clearForm();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Add Season",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: w * 0.013,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon, {
    required VoidCallback onPressed,
    required double w,
  }) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFE5E7EB),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w500,
                fontSize: w * 0.011,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              Icons.calendar_month,
              color: Colors.white,
              size: w * 0.03,
            ),
          ),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Season Management',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Create and manage seasons',
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
                  Icons.add,
                  color: const Color(0xFF4F46E5),
                  size: w * 0.02,
                ),
              ),
              SizedBox(width: w * 0.015),
              Text(
                "Add New Season",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.02,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.03),

          // Fields
          _buildModernTextField(
              label: "Season Number",
              hint: "Enter season number",
              icon: Icons.sports_soccer,
              controller: nameController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              inputType: TextInputType.number),

          SizedBox(height: w * 0.02),

          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  label: "Year",
                  hint: "2024",
                  icon: Icons.calendar_today,
                  controller: yearController,
                ),
              ),
              SizedBox(width: w * 0.02),
              Expanded(child: _buildModernDateField(w)),
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
                } else if (yearController.text.isEmpty) {
                  return showSnackBarToast(context, "Please enter year", "red");
                } else if (endDateController.text.isEmpty) {
                  return showSnackBarToast(
                      context, "Please select end date", "red");
                }

                final confirm =
                    await alert(context, "Do you want to add season?", w, h);

                if (confirm) {
                  final seasonModel = SeasonModel(
                    bestPlayer: "",
                    runner: "",
                    teams: selectedTeams.length,
                    winner: "",
                    endDate: ref.read(endDate)!,
                    seasonName: "SEASON ${nameController.text.trim()}",
                    delete: false,
                    search: setSearchParam(nameController.text.trim()),
                    createdDate: DateTime.now(),
                    year: int.parse(yearController.text.trim()),
                  );

                  ref.read(aslRepositoryProvider).addNewSeason(seasonModel);
                  showSnackBarToast(
                      context, "Season added successfully", "green");
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
                    "Add Season",
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

  Widget _buildModernDateField(double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "End Date",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontSize: w * 0.012,
          ),
        ),
        SizedBox(height: w * 0.008),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2400),
            );
            if (selectedDate != null) {
              ref.read(endDate.notifier).state = selectedDate;
              endDateController.text =
                  DateFormat("dd MMM yyyy").format(selectedDate);
            }
          },
          child: AbsorbPointer(
            child: _buildModernTextField(
              label: "",
              hint: "Select end date",
              icon: Icons.event,
              controller: endDateController,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField(
      {required String label,
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      TextInputType? inputType,
      List<TextInputFormatter>? inputFormatters}) {
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
          padding: EdgeInsets.symmetric(horizontal: 10),
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
            inputFormatters: inputFormatters,
            keyboardType: inputType,
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
                horizontal: MediaQuery.of(context).size.width * 0.02,
                vertical: MediaQuery.of(context).size.width * 0.012,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

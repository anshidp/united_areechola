import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class AddAwardScreen extends ConsumerStatefulWidget {
  const AddAwardScreen({super.key});

  @override
  ConsumerState<AddAwardScreen> createState() => _AddAwardScreenState();
}

class _AddAwardScreenState extends ConsumerState<AddAwardScreen> {
  final selectSeason = StateProvider<String?>((ref) => null);

  final awardKeyController = TextEditingController();
  final awardTitleController = TextEditingController();
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});
  final isImageUploading = StateProvider<bool>((ref) => false);

  String? imageUrl;

  void getSeason() async {
    ref.read(seasons.notifier).state =
        await ref.read(aslRepositoryProvider).getSeasons();
  }

  @override
  void initState() {
    getSeason();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.02),
        child: Column(
          children: [
            _buildHeader(w),
            SizedBox(height: w * 0.03),
            _buildForm(w),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double w) {
    return Container(
      padding: EdgeInsets.all(w * 0.025),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(w * 0.02),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.white, size: w * 0.03),
          SizedBox(width: w * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Season Award",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Create awards dynamically per season",
                style: GoogleFonts.poppins(
                  fontSize: w * 0.012,
                  color: Colors.white70,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildForm(double w) {
    return Container(
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
          /// Season
          _dropdown(
            label: "Season",
            value: ref.watch(selectSeason),
            items: ref.watch(seasons).entries.map((e) {
              return DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (v) => ref.read(selectSeason.notifier).state = v,
          ),

          SizedBox(height: w * 0.02),

          // /// Award Key
          // _textField(
          //   label: "Award Key",
          //   controller: awardKeyController,
          //   hint: "bestSave",
          // ),

          SizedBox(height: w * 0.02),

          /// Award Title
          _textField(
            label: "Award Title",
            controller: awardTitleController,
            hint: "Best Save",
          ),

          SizedBox(height: w * 0.03),

          /// Image Upload
          _imagePicker(w),

          SizedBox(height: w * 0.04),

          /// Save Button
          SizedBox(
            width: double.infinity,
            height: w * 0.04,
            child: ElevatedButton(
              onPressed: _saveAward,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
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
                    Icons.add_circle,
                    size: w * 0.015,
                  ),
                  SizedBox(width: w * 0.01),
                  Text(
                    "Create Award",
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

  Widget _imagePicker(double w) {
    final uploading = ref.watch(isImageUploading);

    return GestureDetector(
      onTap: uploading
          ? null
          : () async {
              ref.read(isImageUploading.notifier).state = true;

              final url =
                  await ref.read(aslRepositoryProvider).uploadAwardImage();

              if (url != null) {
                imageUrl = url;
              }

              ref.read(isImageUploading.notifier).state = false;
              setState(() {});
            },
      child: Container(
        height: w * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(w * 0.01),
          border: Border.all(color: Colors.grey.shade300),
          color: const Color(0xFFF8FAFC),
        ),
        child: uploading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(strokeWidth: 2),
                    const SizedBox(height: 12),
                    Text(
                      "Uploading image...",
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.01,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            : imageUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload,
                          size: 40, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 8),
                      Text(
                        "Upload Award Image",
                        style: GoogleFonts.poppins(
                          fontSize: w * 0.01,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(w * 0.01),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
      ),
    );
  }

  void _saveAward() async {
    if (ref.read(selectSeason) == null) {
      return showSnackBarToast(context, "Please choose season", "red");
    } else if (awardTitleController.text.isEmpty) {
      return showSnackBarToast(context, "Please enter title", "red");
    } 
    // else if (imageUrl == null) {
    //   return showSnackBarToast(context, "Please upload image", "red");
    // }

    await ref.read(aslRepositoryProvider).addSeasonAward(
      seasonId: ref.read(selectSeason)!,
      data: {
        // "key": awardKeyController.text.trim(),
        "title": awardTitleController.text.trim(),
        "imageUrl": imageUrl,
        "enabled": true,
        "createdAt": DateTime.now(),
      },
    );

    if (context.mounted) {
      showSnackBarToast(context, "Award created successfully! 🎉", "green");
    }

    awardKeyController.clear();
    awardTitleController.clear();
    imageUrl = null;
    setState(() {});
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontSize: w * 0.012,
          ),
        ),
        SizedBox(height: w * 0.008),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(w * 0.01),
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
              value: value,
              hint: Text(
                "Select $label",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9CA3AF),
                  fontSize: w * 0.011,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF3B82F6),
                size: w * 0.02,
              ),
              items: items,
              onChanged: onChanged,
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.015,
                vertical: w * 0.005,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontSize: w * 0.012,
          ),
        ),
        SizedBox(height: w * 0.008),
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
              fontSize: w * 0.011,
              color: const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: w * 0.011,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.01),
                borderSide:
                    const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.01),
                borderSide:
                    const BorderSide(color: Color(0xFF3B82F6), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: w * 0.015,
                vertical: w * 0.012,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

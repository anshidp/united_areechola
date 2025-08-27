import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/utils/constants.dart';

class AwardGridPage extends StatefulWidget {
  final String seasonId;
  final Map<String, dynamic> awardTitles;

  const AwardGridPage(
      {super.key, required this.awardTitles, required this.seasonId});

  @override
  State<AwardGridPage> createState() => _AwardGridPageState();
}

class _AwardGridPageState extends State<AwardGridPage> {
  final Map<String, io.File?> selectedImages = {};

  Future<void> pickAndUploadImage(String seasonId, String title) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    setState(() {
      selectedImages[title] = io.File(file.path);
    });

    try {
      // Firebase Storage reference
      final fileName = "$title${DateTime.now().microsecondsSinceEpoch}";
      final ref =
          FirebaseStorage.instance.ref().child("season_images").child(fileName);

      if (kIsWeb) {
        // For Web → upload bytes
        final bytes = await file.readAsBytes();
        await ref.putData(bytes);
      } else {
        // For Mobile → upload File
        await ref.putFile(io.File(file.path));
      }

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      // Update Firestore (merge into 'image' map)
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .set({
        "images": {title: downloadUrl}
      }, SetOptions(merge: true));

      showSnackBar(context, "Image uploaded successfully");
      print("✅ Image uploaded and updated for $title");
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("🏆 Add Award Images"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.awardTitles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: scrWidth > 900 ? 3 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final title = widget.awardTitles.keys.toList()[index];
            String imageFile = widget.awardTitles.values.toList()[index] ?? "";
            io.File? localfile = selectedImages[title];

            return GestureDetector(
              onTap: () => pickAndUploadImage(
                widget.seasonId,
                title,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade800,
                      Colors.deepPurple.shade400
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: localfile != null
                            ? Image.file(localfile,
                                fit: BoxFit.cover, width: double.infinity)
                            : imageFile.isNotEmpty
                                ? Image.network(imageFile,
                                    fit: BoxFit.cover, width: double.infinity)
                                : Container(
                                    color: Colors.white.withOpacity(0.08),
                                    child: const Center(
                                      child: Icon(Icons.add_a_photo,
                                          color: Colors.white, size: 40),
                                    ),
                                  ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: kIsWeb ? scrWidth * 0.012 : scrWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

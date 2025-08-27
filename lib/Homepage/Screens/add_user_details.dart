import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:united_areechola/Models/userdatamodel.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';

// ignore: must_be_immutable
class AddUserDetails extends ConsumerStatefulWidget {
  UserDataModel? userDataModel;
  AddUserDetails({super.key, this.userDataModel});

  @override
  ConsumerState<AddUserDetails> createState() => _AddUserDetailsState();
}

class _AddUserDetailsState extends ConsumerState<AddUserDetails> {
  final isUploading = StateProvider((ref) => false);
  final imageUrl = StateProvider<String?>((ref) => null);
  final imageFile = StateProvider<File?>((ref) => null);

  Future<void> addUserdata(UserDataModel user) async {
    try {
      db
          .collection(FirebaseContants.members)
          .doc(widget.userDataModel?.id)
          .set(user.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  final phonenumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadImage(ImageSource source) async {
    final pickedImage =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedImage != null) {
      final file = File(pickedImage.path);
      ref.read(imageFile.notifier).state = File(pickedImage.path);
      final fileName = basename(file.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      final uploadTask = storageRef.putFile(file);

      // Wait for upload to finish
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      ref.read(imageUrl.notifier).state = downloadUrl;

      print('Uploaded Image URL: ${ref.read(imageUrl)}');
    }
  }

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: scrHeight * 0.08, horizontal: scrwidth * 0.1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Add Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => showImagePickerOptions(context),
                child: Stack(
                  children: [
                    Consumer(builder: (context, ref, _) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage: ref.watch(imageFile) != null
                            ? FileImage(ref.read(imageFile)!)
                            : const AssetImage(
                                    'assets/person-icon-512x483-d7q8hqj4.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      );
                    }),
                    const Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              customTextField("FullName", fullNameController),
              const SizedBox(height: 10),
              customTextField("PhoneNumber", phonenumberController,
                  validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter phonenumber";
                }
                return null;
              }, inputfomater: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ]),
              const SizedBox(height: 10),
              customTextField("Password", passwordController,
                  validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter password";
                } else if (value.length < 6) {
                  return "Please enter 6 digit password";
                }
                return null;
              }),
              Padding(padding: EdgeInsets.only(top: scrwidth * 0.1)),
              ElevatedButton(
                onPressed: () async {
                  if (fullNameController.text.trim().isEmpty) {
                    return showSnackBarMsg(
                        context, "Please enter name", Colors.red);
                  } else if (phonenumberController.text.trim().isEmpty) {
                    return showSnackBarMsg(
                        context, "Please enter PhoneNumber", Colors.red);
                  } else if (passwordController.text.trim().isEmpty) {
                    return showSnackBarMsg(
                        context, "Please enter password", Colors.red);
                  } else if (ref.read(imageUrl) == null) {
                    return showSnackBarMsg(
                        context, "Please upload image", Colors.red);
                  }
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("id", widget.userDataModel?.id ?? "");
                  final user = UserDataModel(
                      id: widget.userDataModel?.id,
                      email: widget.userDataModel?.email ?? "",
                      createdDate: DateTime.now(),
                      delete: false,
                      fullName: fullNameController.text.trim(),
                      password: passwordController.text.trim(),
                      phoneNumber: phonenumberController.text.trim(),
                      photoUrl: ref.read(imageUrl),
                      role: widget.userDataModel?.role ?? "");

                  await addUserdata(user);
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SplashScreen()),
                        (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(scrwidth, scrHeight * 0.05),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    backgroundColor: Color(0xff003F62)),
                child: Text(
                  "Add details",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

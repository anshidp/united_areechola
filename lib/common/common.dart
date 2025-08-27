import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

late double scrwidth;
late double scrHeight;

final db = FirebaseFirestore.instance;
double? subcriptionAmount;

enum MatchStatus { ongoing, fulltime }

class Palette {
  static const primaryColor = Color(0xff0000FF);
  static const Color textColor = Color(0xFF333333);
  static const secondaryColor = Color(0xff7855FF);
  static const colorSideMenu = Color(0xffA6A6A6);
  static const textColourSidemenu = Color(0xffDEDEDE);
  static const whiteColor = Color(0xffFFFFFF);
  static const blackColor = Color(0xff000000);
  static const greyBorder = Color(0xff5E5E5E);
  static Color greyColor = Color(0xffB6B6B6);
  static Color lightPurple = Color(0xe5d394f3);
  static Color lightGreyColor = Color(0xffB6B6B6).withOpacity(0.2);
  static const newColor = Color(0xff6E2C90);
  static const circleColor = Color(0xffECF2FC);
  static Color lightVioletColor = Color(0xffD1D5FF).withOpacity(0.6);
  static Color lightBlueColor = Color(0xffABC7FF).withOpacity(0.6);
  static const greenColor = Color(0xff1D9157);
  static const orengeColor = Color(0xffFF6600);
  static const yellowColor = Color(0xffFFCC00);
  static const redColor = Color(0xfff44336);
  static const newGrey = Color(0xffD9D9D9);
  static const borderColor = Color(0xff8E8E8E);
  static Color lightPink = Color(0xffF2D9FF);
  static Color topColor = Color(0xff162F59);
}

class ImageConstants {
  static const clubLogo = "assets/logo-removebg-preview.png";
}

void showSnackBarToast(BuildContext context, String text, String color) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      webBgColor: color,
      textColor: Colors.white,
      webPosition: "center",
      fontSize: 25.0);
}

void showSnackBarMsg(BuildContext context, String text, Color color) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: color,
          content: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
  }
}

setSearchParam(String caseNumber) {
  List<String> caseSearchList = <String>[];
  String temp = "";

  List<String> nameSplits = caseNumber.split(" ");
  for (int i = 0; i < nameSplits.length; i++) {
    String name = "";

    for (int k = i; k < nameSplits.length; k++) {
      name = "$name${nameSplits[k]} ";
    }
    temp = "";

    for (int j = 0; j < name.length; j++) {
      temp = temp + name[j];
      caseSearchList.add(temp.toUpperCase());
    }
  }
  return caseSearchList;
}

Future<bool> alert(
    BuildContext context, String message, double w, double h) async {
  bool result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Palette.whiteColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0)),
            title: Text(
              'Are you sure?',
              style: GoogleFonts.poppins(
                  fontSize: w * 0.0125,
                  fontWeight: FontWeight.bold,
                  color: Palette.newColor),
            ),
            content: Text(
              message,
              style: GoogleFonts.poppins(color: Palette.blackColor),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(w * 0.11, h * 0.06),
                  backgroundColor: Palette.whiteColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(h * 0.02),
                      side: const BorderSide(color: Palette.whiteColor)),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                      fontSize: w * 0.0125,
                      fontWeight: FontWeight.bold,
                      color: Palette.blackColor),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(w * 0.11, h * 0.06),
                  backgroundColor: Palette.newColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(h * 0.02),
                      side: const BorderSide(color: Palette.newColor)),
                ),
                child: Text(
                  'Sure',
                  style: TextStyle(
                      fontSize: w * 0.0125,
                      fontWeight: FontWeight.bold,
                      color: Palette.whiteColor),
                ),
              ),
            ],
          ));
  return result;
}

Widget customTextField(
  String label,
  TextEditingController controller, {
  List<TextInputFormatter>? inputfomater,
  String? Function(String?)? validator,
  int maxLines = 1,
  ValueChanged<String>? onChanged,
  TextInputType? inputtype,
  bool alignLabelLeft = false,
  String? suffix,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: TextFormField(
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
      keyboardType: inputtype,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputfomater,
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        suffixText: suffix,
        labelStyle: GoogleFonts.inter(fontSize: 13),
        hintStyle: GoogleFonts.inter(fontSize: 13),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          //     borderSide: const BorderSide(color: Colors.blue),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          //     borderSide: const BorderSide(color: Colors.blue),
          borderSide: BorderSide(color: Colors.grey),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          //     borderSide: const BorderSide(color: Colors.blue),
          borderSide: BorderSide(color: Colors.grey),
        ),
        // Always align label to start
        alignLabelWithHint: true,
        floatingLabelAlignment: FloatingLabelAlignment.start,
      ),
    ),
  );
}

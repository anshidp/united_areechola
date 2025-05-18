import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const cardbgColor = Color(0xff21222D);
const primarycolor = Color(0xff003F62);
const secondaryColor = Color(0xffffffff);
const bgcolor = Color(0xff15131C);

const defaultpadding = 20.0;

class MyColors {
  static const primaryColor = Color(0xFF232955);
  static const kGrey = Color(0xFFECF0F5);
  static const kWhite = Colors.white;
  static const kDeep = Colors.deepPurple;
  static const kBlack = Colors.black;
}

search(String search) {
  List<String> searchresult = [];
  for (int i = 0; i <= search.length; i++) {
    for (int j = i + 1; j <= search.length; j++) {
      searchresult.add(search.substring(i, j).toUpperCase());
    }
  }
  return searchresult;
}

void showSnackBar(
  BuildContext context,
  String text,
) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.black,
          content: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
  }
}

Future<bool> addDialog(BuildContext context, String text) async {
  bool? result = await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return SizedBox(
        child: AlertDialog(
          title: Text(
            'Are you sure?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          content: Text(
            text,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Close the dialog.
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                "Ok",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

class FirebaseContants {
  static const transactions = "transactions";
  static const members = "Members";
}

Future<bool> myalert(BuildContext context, String message) async {
  bool result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0)),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: Colors.orange,
                    size: 40,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop(false);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop(true);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red[800]),
                            child: Center(
                              child: Text(
                                "Yes",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ));
  return result;
}

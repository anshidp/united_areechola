import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:united_areechola/authentication/repository/repository.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';

import '../../Models/userdatamodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final RegExp emailvalidator =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 400,
              height: 90,
              child:
                  Image(image: AssetImage("assets/logo-removebg-preview.png")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: customTextField(
                "Email",
                emailController,
                validator: (value) {
                  if ((value ?? "").isEmpty ||
                      !emailvalidator.hasMatch(value ?? "")) {
                    return "Please enter valid email";
                  } else {
                    return null;
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: customTextField("Password", passwordController),
            ),
            InkWell(
              onTap: () async {
                // check login
                if (emailController.text.isEmpty) {
                  return showSnackBarMsg(
                      context, "Please enter email", Colors.red);
                } else if (passwordController.text.isEmpty) {
                  return showSnackBarMsg(
                      context, "Please enter password", Colors.red);
                } else {
                  final isdata = await ref
                      .read(authrepositoryprovider)
                      .signWithEmailPassword(
                          email: emailController.text,
                          password: passwordController.text);

                  if (isdata?.email != emailController.text) {
                    if (context.mounted) {
                      return showSnackBarMsg(
                          context, "user does not exist", Colors.red);
                    }
                  } else {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("id", isdata?.id ?? "");
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SplashScreen()),
                          (route) => false);
                    }
                  }
                }
              },
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primarycolor),
                child: const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
                onTap: () async {
                  //GoogleSignIn().signOut();
                  signinGoogle();
                },
                child: SvgPicture.asset("assets/Google_Icon.svg"))
          ],
        ),
      ),
    );
  }

  Future<UserDataModel?> signinGoogle() async {
    try {
      return ref.read(authrepositoryprovider).googlesignIn(context);
    } catch (e) {
      print(e);
    }
    return null;
  }
}

class CustomFormfield extends StatelessWidget {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String hint;
  final TextEditingController controller;
  String? Function(String?)? validator;
  AutovalidateMode? autovalidateMode;
  FocusNode? focusNode;
  FocusNode? focusNode1;
  CustomFormfield(
      {super.key,
      required this.hint,
      required this.controller,
      this.autovalidateMode,
      this.focusNode,
      this.focusNode1,
      this.validator});

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;

    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox.fromSize(
            size: const Size(300, 50),
            child: TextFormField(
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(focusNode1);
              },
              focusNode: focusNode,
              autovalidateMode: autovalidateMode,
              validator: validator,
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                labelText: hint,
                hintStyle: const TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF6F6F6F),
                ),
                labelStyle: const TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF6F6F6F),
                ),
                focusColor: const Color.fromRGBO(111, 111, 111, 1),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF6F6F6F)),
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF6F6F6F)),
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Colors.red), // Customize the error border color
                  borderRadius: BorderRadius.circular(scrWidth * 0.02),
                ),
                errorStyle: const TextStyle(
                    fontSize: 10), // Customize the error text style
              ),
            ),
          ),
        ],
      ),
    );
  }
}

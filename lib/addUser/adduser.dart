import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:united_areechola/Models/usermodel.dart';
import 'package:united_areechola/addUser/controller/controller.dart';
import 'package:united_areechola/addUser/repository/repository.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';

class AddUsers extends ConsumerStatefulWidget {
  const AddUsers({super.key});

  @override
  ConsumerState<AddUsers> createState() => _AddAdminState();
}

class _AddAdminState extends ConsumerState<AddUsers> {
  final searchAdminProvider = StateProvider((ref) => "");

  String selectedCountryCode = '';

  ScrollController scrollController = ScrollController();

  final addAdminBool = StateProvider((ref) => false);

  //admin add controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  TextEditingController searchController = TextEditingController();

  //admin editing controllers

  @override
  void dispose() {
    scrollController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    searchController.dispose();

    super.dispose();
  }

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  String selectedGroup = "A+";
  String? downloadUrl;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  createUser(addAdmin) {
    Usermodel usermodel = Usermodel(
        age: int.tryParse(ageController.text),
        createdDate: DateTime.now(),
        delete: false,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        bloodGroup: downloadUrl,
        search: search(
            "${nameController.text.trim()} ${emailController.text.trim()} $selectedGroup"));
    ref.read(adduserRepositoryProvider).addUser(usermodel).then((value) {
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      phoneNumberController.clear();
      downloadUrl = '';

      ref.read(addAdminBool.notifier).state = !addAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    var addAdmin = ref.watch(addAdminBool);
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addAdmin == true
                ? Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            //height: scrHeight,
                            decoration: BoxDecoration(
                              color: MyColors.kGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: scrHeight * 0.04,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: TextFormField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              labelText: 'Name',
                                              labelStyle: GoogleFonts.poppins(
                                                color: const Color(0xFF7C8791),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              hintText: 'Please enter name',
                                              hintStyle: GoogleFonts.poppins(
                                                color: const Color(0xFF7C8791),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF7C8791),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF7C8791),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: scrWidth * 0.02,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: IntlPhoneField(
                                            controller: phoneNumberController,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                color: Color(0xFF7C8791),
                                              )),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                color: Color(0xFF7C8791),
                                              )),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFF7C8791),
                                                ),
                                              ),
                                              labelText: 'Phone no',
                                              labelStyle: GoogleFonts.poppins(
                                                  color:
                                                      const Color(0xFF7C8791),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: scrWidth * 0.01),
                                              hintText: 'Please enter phone no',
                                              hintStyle: GoogleFonts.poppins(
                                                color: const Color(0xFF7C8791),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            initialCountryCode: 'IN',
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value!.number.isEmpty) {
                                                return "Please enter phone no";
                                              } else {
                                                return null;
                                              }
                                            },
                                            onChanged: (phone) {
                                              selectedCountryCode =
                                                  phone.countryCode;
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: scrHeight * 0.03,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      // Expanded(
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(10.0),
                                      //     child: TextFormField(
                                      //       controller: emailController,
                                      //       validator: (value) {
                                      //         final emailRegex = RegExp(
                                      //             r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,3}$');
                                      //         if (!emailRegex
                                      //             .hasMatch(value!)) {
                                      //           return 'Please enter a valid email address';
                                      //         }
                                      //         if (value.isEmpty) {
                                      //           return 'Please enter your email';
                                      //         }

                                      //         return null;
                                      //       },
                                      //       decoration: InputDecoration(
                                      //         labelText: 'Email',
                                      //         labelStyle: GoogleFonts.poppins(
                                      //           color: const Color(0xFF7C8791),
                                      //           fontSize: 14,
                                      //           fontWeight: FontWeight.bold,
                                      //         ),
                                      //         hintText: 'Please enter email',
                                      //         hintStyle: GoogleFonts.poppins(
                                      //           color: const Color(0xFF7C8791),
                                      //           fontSize: 14,
                                      //           fontWeight: FontWeight.bold,
                                      //         ),
                                      //         enabledBorder: OutlineInputBorder(
                                      //           borderSide: const BorderSide(
                                      //             color: Color(0xFF7C8791),
                                      //             width: 1,
                                      //           ),
                                      //           borderRadius:
                                      //               BorderRadius.circular(10),
                                      //         ),
                                      //         focusedBorder: OutlineInputBorder(
                                      //           borderSide: const BorderSide(
                                      //             color: Color(0xFF7C8791),
                                      //             width: 1,
                                      //           ),
                                      //           borderRadius:
                                      //               BorderRadius.circular(10),
                                      //         ),
                                      //         filled: true,
                                      //         fillColor: Colors.white,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        width: scrWidth * 0.02,
                                      ),
                                      // Expanded(
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(10.0),
                                      //     child: TextFormField(
                                      //       controller: passwordController,
                                      //       decoration: InputDecoration(
                                      //         labelText: 'Password',
                                      //         labelStyle: GoogleFonts.poppins(
                                      //           color: const Color(0xFF7C8791),
                                      //           fontSize: 14,
                                      //           fontWeight: FontWeight.bold,
                                      //         ),
                                      //         hintText: 'Please enter password',
                                      //         hintStyle: GoogleFonts.poppins(
                                      //           color: const Color(0xFF7C8791),
                                      //           fontSize: 14,
                                      //           fontWeight: FontWeight.bold,
                                      //         ),
                                      //         enabledBorder: OutlineInputBorder(
                                      //           borderSide: const BorderSide(
                                      //             color: Color(0xFF7C8791),
                                      //             width: 1,
                                      //           ),
                                      //           borderRadius:
                                      //               BorderRadius.circular(10),
                                      //         ),
                                      //         focusedBorder: OutlineInputBorder(
                                      //           borderSide: const BorderSide(
                                      //             color: Color(0xFF7C8791),
                                      //             width: 1,
                                      //           ),
                                      //           borderRadius:
                                      //               BorderRadius.circular(10),
                                      //         ),
                                      //         filled: true,
                                      //         fillColor: Colors.white,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(10.0),
                                //   child: TextFormField(
                                //     maxLength: 2,
                                //     keyboardType: TextInputType.number,
                                //     inputFormatters: [
                                //       FilteringTextInputFormatter.digitsOnly
                                //     ],
                                //     controller: ageController,
                                //     decoration: InputDecoration(
                                //       labelText: 'Age',
                                //       labelStyle: GoogleFonts.poppins(
                                //         color: const Color(0xFF7C8791),
                                //         fontSize: 14,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //       hintText: 'Please age',
                                //       hintStyle: GoogleFonts.poppins(
                                //         color: const Color(0xFF7C8791),
                                //         fontSize: 14,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //       enabledBorder: OutlineInputBorder(
                                //         borderSide: const BorderSide(
                                //           color: Color(0xFF7C8791),
                                //           width: 1,
                                //         ),
                                //         borderRadius: BorderRadius.circular(10),
                                //       ),
                                //       focusedBorder: OutlineInputBorder(
                                //         borderSide: const BorderSide(
                                //           color: Color(0xFF7C8791),
                                //           width: 1,
                                //         ),
                                //         borderRadius: BorderRadius.circular(10),
                                //       ),
                                //       filled: true,
                                //       fillColor: Colors.white,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: scrHeight * 0.03,
                                ),
                                Container(
                                  width: scrWidth * 0.4,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE6E6E6),
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                    child: //dropdown
                                        DropdownButtonFormField<String>(
                                      value: selectedGroup,
                                      items: bloodGroups.map((String option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedGroup = newValue!;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                          labelText: 'Select BloodGroup'),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: scrHeight * 0.04,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: scrWidth * 0.08,
                                      height: scrHeight * 0.06,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ref
                                              .read(addAdminBool.notifier)
                                              .state = !addAdmin;
                                          nameController.clear();
                                          phoneNumberController.clear();
                                          emailController.clear();
                                          passwordController.clear();
                                          downloadUrl = '';
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              color: MyColors.kDeep),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: scrWidth * 0.03,
                                    ),
                                    SizedBox(
                                      width: scrWidth * 0.08,
                                      height: scrHeight * 0.06,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          RegExp phnChk =
                                              RegExp(r'^\+?\d{10}$');
                                          final emailRegex = RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,3}$');

                                          if (nameController.text
                                              .trim()
                                              .isEmpty) {
                                            return showSnackBarMsg(
                                                context,
                                                'Please enter name',
                                                Colors.red);
                                          }
                                          if (!phnChk.hasMatch(
                                              phoneNumberController.text
                                                  .trim())) {
                                            return showSnackBarMsg(
                                                context,
                                                'Please enter valid phone number',
                                                Colors.red);
                                          }
                                          // if (emailController.text
                                          //     .trim()
                                          //     .isEmpty) {
                                          //   return showSnackBar(context,
                                          //       'Please enter your email');
                                          // }
                                          // if (!emailRegex.hasMatch(
                                          //     emailController.text.trim())) {
                                          //   return showSnackBar(context,
                                          //       'Please enter valid email');
                                          // }
                                          // if (passwordController.text
                                          //         .trim()
                                          //         .isEmpty ||
                                          //     passwordController.text
                                          //             .trim()
                                          //             .length <
                                          //         8) {
                                          //   return showSnackBar(context,
                                          //       'Please enter password atleast 8 character');
                                          // } else {

                                          // }
                                          addDialog(context, addAdmin);
                                        },
                                        child: Text(
                                          "Submit",
                                          style: GoogleFonts.poppins(
                                              color: MyColors.kDeep,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: scrHeight * 0.03,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            SizedBox(
              height: scrHeight * 0.03,
            ),
            (addAdmin == false)
                ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: scrWidth * 0.06,
                          top: scrWidth * 0.02,
                          bottom: scrWidth * 0.02),
                      child: SizedBox(
                        width: scrWidth * 0.1,
                        height: scrHeight * 0.08,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.primaryColor),
                            onPressed: () {
                              //admin add bool
                              ref.read(addAdminBool.notifier).state = !addAdmin;
                            },
                            child: Text(
                              "Add User",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                  )
                : const SizedBox(),
            SizedBox(
              height: scrHeight * 0.03,
            ),
            SizedBox(
              width: scrWidth * 0.5,
              child: TextFormField(
                controller: searchController,
                obscureText: false,
                onChanged: (value) {
                  ref
                      .read(searchAdminProvider.notifier)
                      .update((state) => value.toUpperCase().trim());
                },
                decoration: InputDecoration(
                  suffix: TextButton(
                    onPressed: () {
                      ref.read(searchAdminProvider.notifier).update(
                        (state) {
                          return searchController.text = '';
                        },
                      );
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                  labelStyle: GoogleFonts.poppins(
                    color: const Color(0xFF7C8791),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Please enter name or bloodGroup',
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF7C8791),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF7C8791),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF7C8791),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF090F13),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              height: scrHeight * 0.06,
            ),
            Consumer(
              builder: (context1, ref2, child1) {
                return SizedBox(
                  width: scrWidth * 0.8,
                  child: ref
                      .watch(getuserStreamprovider(
                          ref2.watch(searchAdminProvider)))
                      .when(
                        data: (userSnapshot) {
                          if (userSnapshot.isEmpty) {
                            return SizedBox(
                              height: scrHeight * 0.4,
                              width: scrWidth * 0.6,
                              child: Center(
                                child: Lottie.asset(
                                    "assets/Animation - 1717412302389.json"),
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                SizedBox(
                                  width: scrWidth * 0.8,
                                  child: DataTable(
                                    border: const TableBorder(
                                        bottom: BorderSide(
                                      color: Colors.black,
                                      width: double.infinity,
                                    )),
                                    checkboxHorizontalMargin: Checkbox.width,
                                    columnSpacing: 10,
                                    dividerThickness: 0.5,
                                    showCheckboxColumn: true,
                                    horizontalMargin: 10,
                                    headingRowColor: WidgetStateProperty.all(
                                        MyColors.primaryColor),
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                        'SI No.',
                                        style: GoogleFonts.poppins(
                                          fontSize: scrWidth * 0.014,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Name',
                                        style: GoogleFonts.poppins(
                                          fontSize: scrWidth * 0.014,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Email',
                                        style: GoogleFonts.poppins(
                                          fontSize: scrWidth * 0.014,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Phone no',
                                        style: GoogleFonts.poppins(
                                          fontSize: scrWidth * 0.014,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Blood Group',
                                        style: GoogleFonts.poppins(
                                          fontSize: scrWidth * 0.014,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )),
                                      DataColumn(
                                          label: Text(
                                        'Delete',
                                        style: GoogleFonts.poppins(
                                          fontSize: scrWidth * 0.014,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      )),
                                    ],
                                    rows: List.generate(
                                      userSnapshot.length,
                                      (index) {
                                        final firstList = userSnapshot
                                            .where((user) =>
                                                user.phoneNumber !=
                                                    "0000000000" &&
                                                (user.email ?? "").isNotEmpty)
                                            .toList();

                                        final noEmailList = userSnapshot
                                            .where((user) =>
                                                user.phoneNumber !=
                                                    "0000000000" &&
                                                (user.email ?? "").isEmpty)
                                            .toList();
                                        final secondList = userSnapshot
                                            .where((user) =>
                                                user.phoneNumber ==
                                                "0000000000")
                                            .toList();

                                        final compainedList = [
                                          ...firstList,
                                          ...noEmailList,
                                          ...secondList
                                        ];

                                        Usermodel usermodel =
                                            compainedList[index];

                                        return DataRow(
                                            color: WidgetStatePropertyAll(
                                                index.isEven
                                                    ? Colors.blueGrey.shade50
                                                        .withOpacity(0.7)
                                                    : Colors.white),
                                            cells: [
                                              DataCell(Text(
                                                '${index + 1}',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                              DataCell(Text(
                                                usermodel.name ?? '',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                              DataCell(Text(
                                                usermodel.email ?? '',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                              DataCell(
                                                Text(
                                                  usermodel.phoneNumber ?? '',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  usermodel.bloodGroup ?? '',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              DataCell(IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    deleteShowDialogue(
                                                        usermodel),
                                              )),
                                            ]);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: scrHeight * 0.05,
                                ),
                              ],
                            );
                          }
                        },
                        error: (error, stackTrace) {
                          print(error);
                          return Text(error.toString());
                        },
                        loading: () => const SizedBox(),
                      ),
                );
              },
            ),
            SizedBox(
              height: scrHeight * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  // delete userDialogue
  deleteShowDialogue(Usermodel user) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Are you sure?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            content: Text(
              "Do you want delete",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog.
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  deleteAdmin(user);
                  Navigator.pop(context);
                },
                child: const Text("Ok"),
              ),
            ],
          );
        });
  }

  Future<void> addDialog(BuildContext context, addadmin) async {
    return showDialog(
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
              'Do you want to user',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog.
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () {
                  createUser(addAdminBool);
                  Navigator.of(context).pop();
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
  }

  void deleteAdmin(Usermodel user) {
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .update({'delete': true});
    } catch (e) {
      throw e.toString();
    }
  }
}
// addUser Dialouge

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/Models/subcription_model.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/subcriptions/repository/repository.dart';

class AddSubcription extends ConsumerStatefulWidget {
  const AddSubcription({super.key});

  @override
  ConsumerState<AddSubcription> createState() => _AddSubcriptionState();
}

class _AddSubcriptionState extends ConsumerState<AddSubcription> {
  int monthlysubcriptionAmount = 50;
  DateTime? subcriptionStartDate;
  void duplicate() async {
    final members =
        await FirebaseFirestore.instance.collection("subcriptionMembers").get();
    final users = FirebaseFirestore.instance.collection("users");
    for (var user in members.docs) {
      await users.add(user.data());
    }
  }

  final amountController = TextEditingController();

  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  int unpaidUsers = 0;

  Future<String> _fetchUser(String userId) async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('subcriptionMembers')
        .doc(userId)
        .get();
    if (userSnapshot.exists) {
      return userSnapshot.data()?['name'];
    } else {
      return "";
    }
  }

  List<User> userslist = [];
  Map<String, dynamic> users = {};
  List<int> monthlyList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  getUsers() async {
    try {
      final data = await FirebaseFirestore.instance
          .collection("subcriptionMembers")
          .get();
      if (data.docs.isNotEmpty) {
        for (var i in data.docs) {
          users[i.id] = i["name"];
        }

        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _updateSelectedMonth(String? newMonth) {
    if (newMonth != null) {
      setState(() {
        selectedMonth = newMonth;
        print("selectedmonth: $selectedMonth");
      });
    }
  }

  List<String> _generateMonthList() {
    List<String> months = [];
    DateTime now = DateTime.now();
    for (int i = -5; i <= 8; i++) {
      DateTime date = DateTime(now.year, now.month + i, 1);
      months.add(DateFormat('yyyy-MM').format(date));
    }
    return months.reversed.toList();
  }

  final dropdownController = TextEditingController();
  final dropdownselectedItem = StateProvider<String?>((ref) => "");
  final dropdownselectedUsername = StateProvider<String?>((ref) => "");
  final dropdownselectedMonth = StateProvider<int?>((ref) => null);

  final addeventbool = StateProvider<bool>((ref) => false);

  Map<String, double> subcriptionamount = {};

  @override
  void initState() {
    getUsers();
    //duplicate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    var addevent = ref.watch(addeventbool);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: ref
                      .read(subcriptionrepositoryprovider)
                      .getEachMonthsubcriptionAmount(
                          selectMonth: selectedMonth),
                  builder: (context, transactionamount) {
                    if (transactionamount.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: Text(''));
                    }
                    if (!transactionamount.hasData) {
                      return const Text(
                        "No data ",
                        style: TextStyle(
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            fontSize: 12),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            //width: scrWidth * 0.34,
                            height: scrHeight * 0.1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "This Month".toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 15,
                                    color: primarycolor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "₹${transactionamount.data?["thisMonth"]}",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 15,
                                    color: primarycolor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            width: scrWidth * 0.4,
                            height: scrHeight * 0.1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Total Amount".toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 15,
                                    color: primarycolor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "₹${transactionamount.data?["total"]}",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 15,
                                    color: primarycolor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              addevent == true
                  ? Column(
                      spacing: 20,
                      children: [
                        SizedBox(),
                        SizedBox(
                            height: 47,
                            width: scrWidth * 0.4,
                            child: DropDownTextField(
                              listTextStyle: TextStyle(
                                fontSize: 13,
                                fontFamily: "PublicSans",
                                color: Colors.black,
                              ),
                              searchTextStyle: TextStyle(
                                fontSize: 13,
                                fontFamily: "PublicSans",
                                color: Colors.black,
                              ),
                              textStyle: TextStyle(
                                fontSize: 13,
                                fontFamily: "PublicSans",
                                color: Colors.black,
                              ),
                              clearOption: false,
                              enableSearch: true,

                              //dropdownColor: textFormFieldFillColor,
                              dropDownList: users.entries
                                  .map((e) => DropDownValueModel(
                                      name: e.value, value: e.key))
                                  .toList(),
                              onChanged: (value) {
                                ref.read(dropdownselectedItem.notifier).state =
                                    value.value;

                                ref
                                    .read(dropdownselectedUsername.notifier)
                                    .state = value.name;
                              },
                              // textFieldFocusNode: stateFocus,
                              textFieldDecoration: InputDecoration(
                                enabled: true,
                                hintText: 'Select user',
                                hintStyle: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: "PublicSans",
                                    color: Color(0xff959FA2)),

                                // fillColor: textFormFieldFillColor,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xff959FA2),
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(scrWidth * 0.001),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xff959FA2),
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(scrWidth * 0.001),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff959FA2)),
                                  borderRadius:
                                      BorderRadius.circular(scrWidth * 0.001),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff959FA2)),
                                  borderRadius:
                                      BorderRadius.circular(scrWidth * 0.001),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xff959FA2)),
                                  borderRadius:
                                      BorderRadius.circular(scrWidth * 0.001),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 47,
                          width: scrWidth * 0.4,
                          child: DropdownMenu(
                              enableSearch: true,
                              inputDecorationTheme: const InputDecorationTheme(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  focusColor: Colors.white,
                                  fillColor: Colors.white,
                                  filled: true),
                              menuStyle: const MenuStyle(
                                  surfaceTintColor:
                                      WidgetStatePropertyAll(Colors.white),
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.white)),
                              width: scrWidth * 0.7,
                              hintText: "Select month",
                              textStyle: const TextStyle(
                                  fontFamily: "Inter", fontSize: 13),
                              enableFilter: true,
                              onSelected: (value) {
                                ref.read(dropdownselectedMonth.notifier).state =
                                    value;

                                setState(() {
                                  int calculatedamount = (ref
                                              .read(dropdownselectedMonth
                                                  .notifier)
                                              .state ??
                                          0) *
                                      monthlysubcriptionAmount;
                                  amountController.text =
                                      calculatedamount.toString();
                                });
                                // ref.read(dropdownselectedItem.notifier).state =
                                //     value;
                              },
                              dropdownMenuEntries: monthlyList.map((e) {
                                return DropdownMenuEntry(
                                    value: e, label: e.toString());
                              }).toList()),
                        ),
                        SizedBox(
                            width: scrWidth * 0.4,
                            child: TextFormField(
                              readOnly: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: amountController,
                              decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: "Amount",
                                  hintStyle: TextStyle(
                                      fontFamily: "Inter", fontSize: 12),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  filled: true,
                                  fillColor: Colors.white),
                            )),
                        // eventformfield(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            addButton(
                                onTap: () async {
                                  if ((ref
                                              .read(
                                                  dropdownselectedItem.notifier)
                                              .state ??
                                          "")
                                      .isEmpty) {
                                    return showSnackBarMsg(context,
                                        "Please choose a user", Colors.red);
                                  } else if (ref
                                          .read(dropdownselectedMonth.notifier)
                                          .state ==
                                      null) {
                                    return showSnackBarMsg(context,
                                        "Please choose a month", Colors.red);
                                  }
                                  bool confirm = await addDialog(
                                      context, "Do you want add subcription?");

                                  if (confirm) {
                                    SubcriptionModel subcription = SubcriptionModel(
                                        month: ref.read(dropdownselectedMonth),
                                        startDate:
                                            DateTime.parse("$selectedMonth-01"),
                                        status: 0,
                                        createdDate: DateTime.now(),
                                        delete: false,
                                        amount: double.tryParse(
                                            amountController.text),
                                        userId: ref.read(dropdownselectedItem),
                                        expireDate: DateTime.parse(
                                                "$selectedMonth-01")
                                            .add(Duration(
                                                days: (ref
                                                            .read(
                                                                dropdownselectedMonth
                                                                    .notifier)
                                                            .state ??
                                                        0) *
                                                    30)));
                                    ref
                                        .read(subcriptionrepositoryprovider)
                                        .addsubcription(
                                            subcriptionModel: subcription);

                                    showSnackBarMsg(
                                        context,
                                        "subcription added successfull",
                                        Colors.green);

                                    amountController.clear();
                                    ref
                                        .watch(dropdownselectedItem.notifier)
                                        .state = null;
                                    ref
                                        .watch(dropdownselectedMonth.notifier)
                                        .state = null;
                                  }

                                  ref.watch(addeventbool.notifier).state =
                                      !ref.watch(addeventbool.notifier).state;
                                },
                                title: 'Add Subcription'),
                            const SizedBox(
                              width: 20,
                            ),
                            addButton(
                                onTap: () {
                                  ref.read(addeventbool.notifier).state =
                                      !addevent;
                                },
                                title: 'Cancel'),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox(),
              (addevent == false && isAdmin)
                  ? Consumer(builder: (context, ref, child) {
                      return Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: scrWidth * 0.06,
                              top: scrWidth * 0.02,
                              bottom: scrWidth * 0.02),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width >= 600
                                ? scrWidth * 0.16
                                : scrWidth * 0.4,
                            height: scrHeight * 0.054,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: MyColors.primaryColor),
                                onPressed: () {
                                  //admin add bool
                                  ref.read(addeventbool.notifier).state =
                                      !addevent;
                                },
                                child: Text(
                                  "Add Subcription",
                                  style: TextStyle(
                                      fontSize: scrWidth >= 600
                                          ? scrWidth * 0.009
                                          : scrWidth * 0.03,
                                      fontFamily: "Inter",
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                      );
                    })
                  : const SizedBox(),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: scrWidth * 0.5,
                height: scrHeight * 0.3,
                child: FutureBuilder(
                    future: ref
                        .read(subcriptionrepositoryprovider)
                        .getunpaidUsers(selectedMonth),
                    builder: (context, unpaidusers) {
                      if (unpaidusers.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: Text(''));
                      }
                      if (!unpaidusers.hasData) {
                        return const Text(
                          "No data ",
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        );
                      }
                      unpaidUsers = (unpaidusers.data?.length ?? 0);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Unpaid Users: $unpaidUsers",
                              style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            SizedBox(
                              height: scrHeight * 0.03,
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: unpaidusers.data?.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor:
                                                  Color(0xffDA4D4A),
                                              radius: 4,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: scrWidth*0.35),
                                              child: Text(
                                                '${unpaidusers.data?[index].toUpperCase()}',
                                                style: const TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.shade500,
                      )),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      onChanged: _updateSelectedMonth,
                      items: _generateMonthList()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 13,
                                color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: ref
                      .read(subcriptionrepositoryprovider)
                      .getSubcriptionTransactions(selectedMonth: selectedMonth),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: Text(
                        "No Data Found",
                        style: TextStyle(fontFamily: "Inter", fontSize: 13),
                      ));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text(''));
                    }
                    return LayoutBuilder(builder: (context, constrains) {
                      return SizedBox(
                        // width: 400,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            dataTextStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            border: TableBorder.all(
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromARGB(255, 211, 192, 192)),
                            headingRowColor:
                                const WidgetStatePropertyAll(Color(0xffF4F4F4)),
                            columns: kIsWeb
                                ? const [
                                    DataColumn(
                                        label: Text(
                                      "No",
                                      style: TextStyle(
                                          fontFamily: "Inter",
                                          fontSize: 12,
                                          color: Colors.black),
                                    )),
                                    DataColumn(
                                        label: Text("Name",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                color: Colors.black))),
                                    DataColumn(
                                        label: Text("Amount",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                color: Colors.black))),
                                    DataColumn(
                                        label: Text("Date",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                color: Colors.black))),
                                    DataColumn(
                                        label: Text("Status",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                color: Colors.black))),
                                    DataColumn(
                                        label: Text("Delete",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                color: Colors.black))),
                                  ]
                                : [
                                    const DataColumn(
                                        label: Text(
                                      "No",
                                      style: TextStyle(
                                          fontFamily: "Inter",
                                          fontSize: 12,
                                          color: Colors.black),
                                    )),
                                    const DataColumn(
                                        label: Text("Name",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                color: Colors.black))),
                                    const DataColumn(
                                        label: Text("Amount",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                color: Colors.black))),
                                    if (isAdmin)
                                      DataColumn(
                                          label: Text("Delete",
                                              style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 12,
                                                  color: Colors.black))),
                                  ],
                            rows: List.generate((snapshot.data ?? []).length,
                                (index) {
                              final data = snapshot.data?[index];
                              return DataRow(
                                  color: const WidgetStatePropertyAll(
                                      Color(0xffFFFFFF)),
                                  cells: [
                                    DataCell(Text("${index + 1}",
                                        style: const TextStyle(
                                            fontFamily: "Inter",
                                            fontSize: 13,
                                            color: Colors.black))),
                                    DataCell(FutureBuilder(
                                        future: _fetchUser(data?.userId ?? ""),
                                        builder: (context, username) {
                                          return Text(username.data?.toUpperCase() ?? "",
                                              style: const TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 13,
                                                  color: Colors.black));
                                        })),
                                    DataCell(Text((() {
                                      final amount = data?.amount ?? 0;
                                      final month = data?.month ?? 0;
                                      if (month == 0) return "0";
                                      return (amount / month)
                                          .toInt()
                                          .toString();
                                    })(),
                                        style: const TextStyle(
                                            fontFamily: "Inter",
                                            fontSize: 12,
                                            color: Colors.black))),
                                    if (kIsWeb)
                                      DataCell(Text(
                                          DateFormat("dd-MM-yyyy").format(
                                              data?.createdDate ??
                                                  DateTime.now()),
                                          style: const TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: 12,
                                              color: Colors.black))),
                                    if (kIsWeb)
                                      const DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 5,
                                              backgroundColor:
                                                  Color(0xff4CE080),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("Active",
                                                style: TextStyle(
                                                    fontFamily: "Inter",
                                                    fontSize: 12,
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                    if (isAdmin)
                                      DataCell(IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          bool delete = await addDialog(context,
                                              "Do you want to delete the transaction?");
                                          if (delete) {
                                            deleteUser(transId: data?.id ?? "");
                                            if (context.mounted) {
                                              showSnackBarMsg(
                                                  context,
                                                  "Transaction deleted successfully",
                                                  Colors.red);
                                            }
                                          }
                                        },
                                      )),
                                  ]);
                            }),
                          ),
                        ),
                      );
                    });
                  })
            ],
          ),
        ),
      ),
    );
  }

  void deleteUser({required String transId}) {
    try {
      FirebaseFirestore.instance
          .collection("transactions")
          .doc(transId)
          .update({"delete": true});
    } catch (e) {}
  }

  Widget addButton({required Function()? onTap, required String title}) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: scrWidth > 600 ? 150 : scrWidth * 0.35,
        height: scrWidth > 600 ? 50 : scrWidth * 0.12,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(0xff003F62)),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                fontSize: scrWidth > 600 ? 13 : scrWidth * 0.032,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget eventformfield() {
    return SizedBox(
      height: 47,
      width: 150,
      child: TextFormField(
        onTap: () async {
          final data = await showDatePicker(
              initialDate: DateTime.now(),
              context: context,
              firstDate: DateTime(2024),
              lastDate: DateTime(2100));
          if (data != null) {
            setState(() {
              subcriptionStartDate = data;
            });
          }
        },
        readOnly: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: subcriptionStartDate != null
            ? TextEditingController(
                text: DateFormat("dd-MM-yyyy").format(subcriptionStartDate!))
            : TextEditingController(),
        decoration: const InputDecoration(
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            hintText: "Start Date",
            hintStyle: TextStyle(fontFamily: "Inter", fontSize: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                borderSide: BorderSide(color: Colors.black)),
            filled: true,
            fillColor: Colors.white),
      ),
    );
  }
}

class User {
  final String userId;
  final String username;
  final DateTime createdDate;
  final int amount;
  User(
      {required this.createdDate,
      required this.amount,
      required this.userId,
      required this.username});

  factory User.fromMap(Map<String, dynamic> map, String userId) {
    return User(
      amount: map["amount"],
      createdDate: map["createdDate"].toDate(),
      userId: userId,
      username: map['name'],
    );
  }
}

class Transaction {
  final DateTime createdDate;
  final int amount;

  Transaction({
    required this.createdDate,
    required this.amount,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      createdDate: map['createdDate'].toDate(),
      amount: map['amount'],
    );
  }
}

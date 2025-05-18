import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/Models/event_expense_model.dart';
import 'package:united_areechola/Models/eventmodel.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/events/repository/repository.dart';
import 'package:united_areechola/events/screens/addDemo_user.dart';
import 'package:united_areechola/events/screens/event_expenses.dart';
import 'package:united_areechola/events/widget/event_transactions_tiles.dart';
import 'package:united_areechola/pdf/services.dart';

import '../../Models/event_transaction_model.dart';

class EventTransactionsScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  const EventTransactionsScreen({super.key, required this.eventModel});

  @override
  ConsumerState<EventTransactionsScreen> createState() =>
      _EventTransactionsState();
}

class _EventTransactionsState extends ConsumerState<EventTransactionsScreen> {
  Map<String, dynamic> users = {};
  getUsers() async {
    try {
      final data = await FirebaseFirestore.instance.collection("users").get();
      if (data.docs.isNotEmpty) {
        for (var user in data.docs) {
          final docdata = user.data();
          if (docdata.containsKey('name')) {
            if (!(widget.eventModel.users ?? []).contains(user.id)) {
              users[user.id] = user["name"];
            }
          } else {
            debugPrint("Document ${user.id} does not have a 'name' field.");
          }
        }

        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  final amountController = TextEditingController();
  final searchController = TextEditingController();
  final expenseController = TextEditingController();
  final dropdownController = SingleValueDropDownController();
  final isAddTransaction = StateProvider<bool>((ref) => false);
  bool transaction = false;
  final isAddExpenses = StateProvider<bool>((ref) => false);
  final dropdownselectedItem = StateProvider<String?>((ref) => "");
  final dropdownselectedUsername = StateProvider<String?>((ref) => "");
  double highestamount = 0;
  String highestPayer = "";

  final isDemoUser = StateProvider((ref) => false);

  final usersearch = StateProvider((ref) => "");

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  void cleardropdown() {
    dropdownController.clearDropDown();
    ref.read(dropdownselectedItem.notifier).state = null;
    ref.read(dropdownselectedUsername.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    var transaction = ref.watch(isAddTransaction);
    var expense = ref.watch(isAddExpenses);
    return Scaffold(
      appBar: AppBar(
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (ref.watch(isAddTransaction))
                    button(
                        onTap: () {
                          ref.read(isDemoUser.notifier).state = true;
                        },
                        title: "DemoUser")
                  else
                    SizedBox()
                ],
              ),
              if (ref.watch(isDemoUser))
                AddDemoUser(
                  eventId: widget.eventModel.eventId ?? "",
                )
              else
                //! Transaction details
                Column(
                  children: [
                    transaction == true && isAdmin
                        ? Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Amount",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall),
                                  Padding(padding: EdgeInsets.only(top: 5)),
                                  SizedBox(
                                      height: 47,
                                      width: scrWidth * 0.4,
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        controller: amountController,
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff959FA2))),
                                          hintText: "Amount",
                                          hintStyle: TextStyle(
                                              fontFamily: "PublicSans",
                                              fontSize: 12,
                                              color: Color(0xff959FA2)),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)),
                                              borderSide: BorderSide(
                                                  color: Color(0xff959FA2))),
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Consumer(builder: (context, ref, child) {
                                ref.watch(isAddExpenses);
                                ref.watch(dropdownselectedItem);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Select user",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    Padding(padding: EdgeInsets.only(top: 5)),
                                    SizedBox(
                                        height: 47,
                                        width: scrWidth * 0.4,
                                        child: DropDownTextField(
                                          controller: dropdownController,
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
                                            if (value is DropDownValueModel) {
                                              ref
                                                  .read(dropdownselectedItem
                                                      .notifier)
                                                  .state = value.value;
                                              ref
                                                  .read(dropdownselectedUsername
                                                      .notifier)
                                                  .state = value.name;
                                            } else {
                                              ref
                                                  .read(dropdownselectedItem
                                                      .notifier)
                                                  .state = null;
                                              ref
                                                  .read(dropdownselectedUsername
                                                      .notifier)
                                                  .state = null;
                                            }
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
                                                  BorderRadius.circular(
                                                      scrWidth * 0.001),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xff959FA2),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      scrWidth * 0.001),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff959FA2)),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      scrWidth * 0.001),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff959FA2)),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      scrWidth * 0.001),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xff959FA2)),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      scrWidth * 0.001),
                                            ),
                                          ),
                                        )),
                                  ],
                                );
                              }),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    button(
                                        onTap: () {
                                          amountController.clear();
                                          ref
                                              .read(
                                                  dropdownselectedItem.notifier)
                                              .state = null;
                                          ref
                                              .read(
                                                  dropdownselectedItem.notifier)
                                              .state = null;
                                          // dropdownController.clear();
                                          ref
                                                  .read(isAddTransaction.notifier)
                                                  .state =
                                              !ref
                                                  .read(
                                                      isAddTransaction.notifier)
                                                  .state;
                                        },
                                        title: "Cancel"),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    button(
                                        onTap: () async {
                                          final eventtransactions =
                                              EventTransactionModel(
                                                  search: search(ref.read(
                                                          dropdownselectedUsername) ??
                                                      ""),
                                                  delete: false,
                                                  amount: double.tryParse(
                                                      amountController.text),
                                                  createdDate: DateTime.now(),
                                                  userId: ref.read(
                                                      dropdownselectedItem),
                                                  eventId: widget
                                                      .eventModel.eventId);
                                          if (((ref.read(
                                                      dropdownselectedItem) ??
                                                  ""))
                                              .isEmpty) {
                                            return showSnackBarMsg(
                                                context,
                                                "Please choose a user",
                                                Colors.red);
                                          }
                                          if (amountController.text.isEmpty) {
                                            return showSnackBarMsg(
                                                context,
                                                "Please enter a amount",
                                                Colors.red);
                                          }
                                          bool confirm = await addDialog(
                                              context,
                                              "Do you want add this Transaction?");
                                          if (confirm) {
                                            ref
                                                .read(eventrepositoryProvider)
                                                .addEventsTransaction(
                                                    eventTransactionModel:
                                                        eventtransactions,
                                                    eventId: widget.eventModel
                                                            .eventId ??
                                                        "");
                                            if (context.mounted) {
                                              showSnackBarMsg(
                                                  context,
                                                  "Transaction Added successfull",
                                                  Colors.red);
                                            }

                                            // ref
                                            //         .read(isAddTransaction.notifier)
                                            //         .state =
                                            //     !ref
                                            //         .read(isAddTransaction
                                            //             .notifier)
                                            //         .state;
                                            // amountController.clear();
                                            cleardropdown();
                                          }
                                        },
                                        title: "Add Transaction"),
                                  ],
                                ),
                              )
                            ],
                          )
                        : const SizedBox(),
                    expense == true && isAdmin
                        ? Column(
                            children: [
                              Consumer(builder: (context, ref, child) {
                                ref.watch(isAddExpenses);
                                ref.watch(dropdownselectedItem);
                                return SizedBox(
                                    width: 300,
                                    height: 47,
                                    child: TextFormField(
                                      controller: expenseController,
                                      decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black)),
                                          hintText: "Expense",
                                          hintStyle: TextStyle(
                                              fontFamily: "PublicSans",
                                              fontSize: 12),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              borderSide: BorderSide(
                                                  color: Colors.black)),
                                          filled: true,
                                          fillColor: Colors.white),
                                    ));
                              }),
                              const SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                  width: 300,
                                  height: 50,
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: amountController,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black)),
                                        hintText: "Amount",
                                        hintStyle: TextStyle(
                                            fontFamily: "PublicSans",
                                            fontSize: 12),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                                color: Colors.black)),
                                        filled: true,
                                        fillColor: Colors.white),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 13.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    button(
                                        onTap: () {
                                          ref
                                              .read(isAddExpenses.notifier)
                                              .state = !ref.read(isAddExpenses);
                                        },
                                        title: "Cancel"),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (isAdmin)
                                      button(
                                          onTap: () async {
                                            final eventExpenses =
                                                EventExpenseModel(
                                                    expenseName: expenseController
                                                        .text
                                                        .trim(),
                                                    amount: double.tryParse(
                                                        amountController.text),
                                                    createdDate: DateTime.now(),
                                                    userId: ref.read(
                                                        dropdownselectedItem),
                                                    eventId: widget
                                                        .eventModel.eventId);
                                            if (expenseController.text
                                                .trim()
                                                .isEmpty) {
                                              return showSnackBarMsg(
                                                  context,
                                                  'Please enter expense name',
                                                  Colors.red);
                                            } else if (amountController.text
                                                .trim()
                                                .isEmpty) {
                                              return showSnackBarMsg(
                                                  context,
                                                  'Please enter amount',
                                                  Colors.red);
                                            }
                                            bool confirm = await addDialog(
                                                context,
                                                "Do you want add Expense?");
                                            if (confirm) {
                                              ref
                                                  .read(eventrepositoryProvider)
                                                  .addEventsExpense(
                                                      eventExpenseModel:
                                                          eventExpenses,
                                                      eventId: widget.eventModel
                                                              .eventId ??
                                                          "");
                                              if (context.mounted) {
                                                showSnackBarMsg(
                                                    context,
                                                    "Expense Added successfull",
                                                    Colors.red);
                                              }

                                              // ref
                                              //         .read(isAddExpenses.notifier)
                                              //         .state =
                                              //     !ref
                                              //         .read(isAddExpenses
                                              //             .notifier)
                                              //         .state;
                                              expenseController.clear();
                                              amountController.clear();
                                            }
                                          },
                                          title: "Add Expense"),
                                  ],
                                ),
                              )
                            ],
                          )
                        : const SizedBox(),
                    //! Add income Button
                    (transaction == false && expense == false && isAdmin
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Consumer(builder: (context, ref, child) {
                                    ref.watch(isAddTransaction);
                                    ref.watch(isAddExpenses);
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: scrWidth * 0.02,
                                          bottom: scrWidth * 0.02),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width >=
                                                    600
                                                ? scrWidth * 0.16
                                                : scrWidth * 0.4,
                                        height: scrHeight * 0.054,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: primarycolor),
                                            onPressed: () {
                                              ref
                                                      .read(isAddTransaction
                                                          .notifier)
                                                      .state =
                                                  !ref.read(isAddTransaction);
                                            },
                                            child: Text(
                                              "Add Income",
                                              style: TextStyle(
                                                  fontSize: scrWidth > 600
                                                      ? 13
                                                      : scrWidth * 0.03,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                    );
                                  }),
                                  Consumer(builder: (context, ref, child) {
                                    ref.watch(isAddTransaction);
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: scrWidth * 0.02,
                                          bottom: scrWidth * 0.02),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width >=
                                                    600
                                                ? scrWidth * 0.16
                                                : scrWidth * 0.35,
                                        height: scrHeight * 0.054,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: primarycolor),
                                            onPressed: () {
                                              ref
                                                      .read(isAddExpenses.notifier)
                                                      .state =
                                                  !ref.read(isAddExpenses);
                                            },
                                            child: Text(
                                              "Add Expense",
                                              style: TextStyle(
                                                  fontSize: scrWidth > 600
                                                      ? 13
                                                      : scrWidth * 0.03,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox()),
                    //! Transactions Details titles
                    scrWidth < 600
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    TransactionTiles(
                                      title: "Event Name",
                                      body: widget.eventModel.eventname,
                                      bgcolor: const Color(0xffF6F1FF),
                                    ),
                                    TransactionTiles(
                                      title: "Date",
                                      body: DateFormat("dd-MM-yyyy").format(
                                          widget.eventModel.createdDate!),
                                      bgcolor: const Color(0xffFFF5EB),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    StreamBuilder<double>(
                                        stream: FirebaseFirestore.instance
                                            .collection("events")
                                            .doc(widget.eventModel.eventId)
                                            .snapshots()
                                            .map((event) => event["totalIncome"]
                                                .toDouble()),
                                        builder: (context, snapshot) {
                                          return TransactionTiles(
                                            title: "Income",
                                            body: snapshot.data,
                                            bgcolor: const Color(0xffEBF0FE),
                                          );
                                        }),
                                    StreamBuilder<double>(
                                        stream: FirebaseFirestore.instance
                                            .collection("events")
                                            .doc(widget.eventModel.eventId)
                                            .snapshots()
                                            .map((event) =>
                                                event["totalexpense"]
                                                    .toDouble()),
                                        builder: (context, snapshot) {
                                          return GestureDetector(
                                            onTap: () {
                                              if ((snapshot.data ?? 0) > 0) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EventExpensesScreen(
                                                              eventId: widget
                                                                      .eventModel
                                                                      .eventId ??
                                                                  "",
                                                            )));
                                              }
                                            },
                                            child: TransactionTiles(
                                              title: "Expense",
                                              body: snapshot.data,
                                              bgcolor: const Color(0xffF3F5F2),
                                            ),
                                          );
                                        }),
                                  ],
                                )
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              TransactionTiles(
                                title: "Event Name",
                                body: widget.eventModel.eventname,
                                bgcolor: const Color(0xffF6F1FF),
                              ),
                              TransactionTiles(
                                title: "Starting Date",
                                body: DateFormat("dd-MM-yyyy")
                                    .format(widget.eventModel.createdDate!),
                                bgcolor: const Color(0xffFFF5EB),
                              ),
                              StreamBuilder<double>(
                                  stream: FirebaseFirestore.instance
                                      .collection("events")
                                      .doc(widget.eventModel.eventId)
                                      .snapshots()
                                      .map((event) =>
                                          event["totalIncome"].toDouble()),
                                  builder: (context, snapshot) {
                                    return TransactionTiles(
                                      title: "Income",
                                      body: snapshot.data,
                                      bgcolor: const Color(0xffEBF0FE),
                                    );
                                  }),
                              StreamBuilder<double>(
                                  stream: FirebaseFirestore.instance
                                      .collection("events")
                                      .doc(widget.eventModel.eventId)
                                      .snapshots()
                                      .map((event) =>
                                          event["totalexpense"].toDouble()),
                                  builder: (context, snapshot) {
                                    return GestureDetector(
                                      onTap: () {
                                        if ((snapshot.data ?? 0) > 0) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventExpensesScreen(
                                                        eventId: widget
                                                                .eventModel
                                                                .eventId ??
                                                            "",
                                                      )));
                                        }
                                      },
                                      child: TransactionTiles(
                                        title: "Expense",
                                        body: snapshot.data,
                                        bgcolor: const Color(0xffF3F5F2),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
              //! Add Expense Texfields
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff003F62),
                            fixedSize:
                                Size(scrWidth * 0.34, scrHeight * 0.013)),
                        onPressed: () {
                          //! Download pdf
                          Transactionpdf().downloadPdf(
                              ctx: context,
                              eventName: widget.eventModel.eventname ?? "",
                              eventId: widget.eventModel.eventId ?? "");
                        },
                        child: Text(
                          "Download pdf",
                          style: TextStyle(
                              fontFamily: "inter",
                              fontSize: scrWidth * 0.03,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Highest income payer
              // const Text(
              //   "Highest Payer",
              //   style: TextStyle(fontFamily: "PublicSans", fontSize: 13),
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // highestIncomePayer(highestamount, highestPayer),
              // const SizedBox(
              //   height: 20,
              // ),
              // search field
              SizedBox(
                  width: scrWidth * 0.5,
                  height: scrHeight * 0.07,
                  child: TextFormField(
                    onChanged: (val) {
                      ref.read(usersearch.notifier).state = val;
                    },
                    controller: searchController,
                    decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        hintText: "Search user",
                        hintStyle:
                            TextStyle(fontFamily: "PublicSans", fontSize: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(color: Colors.black)),
                        filled: true,
                        fillColor: Colors.white),
                  )),
              const SizedBox(
                height: 20,
              ),

              // Transactions Table

              Consumer(builder: (context, ref, child) {
                ref.watch(usersearch);
                Map data = {
                  "eventId": widget.eventModel.eventId,
                  "search": ref.read(usersearch)
                };
                return ref.watch(eventTransactionStream(jsonEncode(data))).when(
                    data: (transactionData) {
                  return SizedBox(
                    width: double.infinity,
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
                          color: const Color.fromARGB(255, 211, 192, 192)),
                      headingRowColor:
                          const WidgetStatePropertyAll(Color(0xffF4F4F4)),
                      columns: kIsWeb
                          ? [
                              DataColumn(
                                  label: Text(
                                "No",
                                style: TextStyle(
                                    fontFamily: "PublicSans",
                                    fontSize: 12,
                                    color: Colors.black),
                              )),
                              DataColumn(
                                  label: Text("Name",
                                      style: TextStyle(
                                          fontFamily: "PublicSans",
                                          fontSize: 12,
                                          color: Colors.black))),
                              DataColumn(
                                  label: Text("Amount",
                                      style: TextStyle(
                                          fontFamily: "PublicSans",
                                          fontSize: 12,
                                          color: Colors.black))),
                              DataColumn(
                                  label: Text("Date",
                                      style: TextStyle(
                                          fontFamily: "PublicSans",
                                          fontSize: 12,
                                          color: Colors.black))),
                              DataColumn(
                                  label: Text("Delete",
                                      style: TextStyle(
                                          fontFamily: "PublicSans",
                                          fontSize: 12,
                                          color: Colors.black))),
                            ]
                          : [
                              DataColumn(
                                  label: Text(
                                "No",
                                style: TextStyle(
                                    fontFamily: "PublicSans",
                                    fontSize: 12,
                                    color: Colors.black),
                              )),
                              DataColumn(
                                  label: Text("Name",
                                      style: TextStyle(
                                          fontFamily: "PublicSans",
                                          fontSize: 12,
                                          color: Colors.black))),
                              DataColumn(
                                  label: Text("Amount",
                                      style: TextStyle(
                                          fontFamily: "PublicSans",
                                          fontSize: 12,
                                          color: Colors.black))),
                            ],
                      rows: List.generate(transactionData.length, (index) {
                        if ((transactionData[index].amount ?? 0) >
                            highestamount) {
                          highestamount = (transactionData[index].amount ?? 0);
                          highestPayer = transactionData[index].userId ?? '';
                        }

                        return DataRow(
                            color:
                                const WidgetStatePropertyAll(Color(0xffFFFFFF)),
                            cells: kIsWeb
                                ? [
                                    DataCell(Text("${index + 1}",
                                        style: const TextStyle(
                                            fontFamily: "PublicSans",
                                            fontSize: 13,
                                            color: Colors.black))),
                                    DataCell(transactionData[index].userId == ""
                                        ? Text(
                                            transactionData[index].username ??
                                                "")
                                        : FutureBuilder<String>(
                                            future: FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(transactionData[index]
                                                    .userId)
                                                .get()
                                                .then((value) =>
                                                    value.data()?["name"]),
                                            builder: (context, snapshot) {
                                              return Text(
                                                  "${snapshot.data?.toUpperCase()}",
                                                  style: const TextStyle(
                                                      fontFamily: "PublicSans",
                                                      fontSize: 13,
                                                      color: Colors.black));
                                            })),
                                    DataCell(Text(
                                        "${transactionData[index].amount}",
                                        style: const TextStyle(
                                            fontFamily: "PublicSans",
                                            fontSize: 12,
                                            color: Colors.black))),
                                    DataCell(Text(
                                        DateFormat("dd-MM-yyyy").format(
                                            transactionData[index]
                                                .createdDate!),
                                        style: const TextStyle(
                                            fontFamily: "PublicSans",
                                            fontSize: 12,
                                            color: Colors.black))),
                                    DataCell(IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        bool delete = await addDialog(context,
                                            "Do you want delete the Transaction?");
                                        if (delete) {
                                          deleteUser(
                                              eventId:
                                                  widget.eventModel.eventId ??
                                                      "",
                                              transId:
                                                  transactionData[index].id ??
                                                      "");
                                          if (context.mounted) {
                                            showSnackBarMsg(context,
                                                "Deleted success", Colors.red);
                                          }
                                        }
                                      },
                                    )),
                                  ]
                                : [
                                    DataCell(Text("${index + 1}",
                                        style: const TextStyle(
                                            fontFamily: "PublicSans",
                                            fontSize: 13,
                                            color: Colors.black))),
                                    DataCell(transactionData[index].userId == ""
                                        ? Text(
                                            transactionData[index].username ??
                                                "")
                                        : FutureBuilder<String>(
                                            future: FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(transactionData[index]
                                                    .userId)
                                                .get()
                                                .then((value) =>
                                                    value.data()?["name"]),
                                            builder: (context, snapshot) {
                                              return Text(
                                                  "${snapshot.data?.toUpperCase()}",
                                                  style: const TextStyle(
                                                      fontFamily: "PublicSans",
                                                      fontSize: 13,
                                                      color: Colors.black));
                                            })),
                                    DataCell(Text(
                                        "${transactionData[index].amount}",
                                        style: const TextStyle(
                                            fontFamily: "PublicSans",
                                            fontSize: 12,
                                            color: Colors.black))),
                                  ]);
                      }),
                    ),
                  );
                }, error: (Object error, StackTrace stackTrace) {
                  print(error);
                  print(stackTrace);
                  return Text(error.toString());
                }, loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
              })
            ],
          ),
        ),
      ),
    );
  }

  void deleteUser({required String eventId, required String transId}) {
    try {
      FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("Transactions")
          .doc(transId)
          .update({"delete": true});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget button({required Function()? onTap, required String title}) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: scrWidth > 600 ? 200 : scrWidth * 0.3,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xff003F62)),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                fontSize: scrWidth > 600 ? 14 : 11,
                fontFamily: "PublicSans",
                fontWeight: FontWeight.w500,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget highestIncomePayer(double income, String id) {
    return Container(
      width: 250,
      height: 60,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.blueGrey,
            spreadRadius: 0.5,
            blurRadius: 2,
          )
          //offset: Offset(1, 4))
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          id.isNotEmpty
              ? FutureBuilder<String>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(id)
                      .get()
                      .then((value) => value["name"]),
                  builder: (context, name) {
                    if (name.connectionState == ConnectionState.waiting) {
                      return const Text("waiting");
                    }
                    return Text(
                      (name.data ?? "").toUpperCase(),
                      style: const TextStyle(
                          fontFamily: "PublicSans",
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    );
                  })
              : const Text("No name"),
          Text(
            income.toString(),
            style: const TextStyle(
                fontFamily: "PublicSans",
                fontSize: 13,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}

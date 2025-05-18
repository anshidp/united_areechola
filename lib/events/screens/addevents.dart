// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:united_areechola/Models/eventmodel.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/events/repository/repository.dart';
import 'package:united_areechola/events/screens/event_transactions.dart';

class AddEvents extends ConsumerStatefulWidget {
  const AddEvents({super.key});

  @override
  ConsumerState<AddEvents> createState() => _AddEventsState();
}

class _AddEventsState extends ConsumerState<AddEvents> {
  update() async {
    final data = await FirebaseFirestore.instance.collection("users").get();
    if (data.docs.isNotEmpty) {
      for (var i in data.docs) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(i.id)
            .update({"id": i.id});
      }
    }
  }

  final addeventbool = StateProvider<bool>((ref) => false);
  final eventnameController = TextEditingController();
  final targetamountController = TextEditingController();
  final discriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var addevent = ref.watch(addeventbool);
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              addevent == true
                  ? Column(
                      children: [
                        Text(
                          "Events",
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        eventformfield(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            addButton(
                                onTap: () async {
                                  if (eventnameController.text.isEmpty) {
                                    return showSnackBar(
                                        context, "Please enter the eventname");
                                  }

                                  bool confirm = await addDialog(
                                      context, "Do you want add this event?");

                                  if (confirm) {
                                    EventModel eventModel = EventModel(
                                        delete: false,
                                        discription: discriptionController.text,
                                        targetamount: double.tryParse(
                                            targetamountController.text),
                                        balance: 0,
                                        income: 0,
                                        createdDate: DateTime.now(),
                                        eventname: eventnameController.text,
                                        users: [],
                                        expense: 0);
                                    ref
                                        .read(eventrepositoryProvider)
                                        .addEvents(eventModel);
                                  }
                                  // showSnackBar(
                                  //     localcontext, "Event added successfull");
                                  ref.read(addeventbool.notifier).state =
                                      !ref.read(addeventbool);
                                },
                                title: 'Add Event'),
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
                              top: scrWidth * 0.06,
                              bottom: scrWidth * 0.02),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width >= 600
                                ? scrWidth * 0.16
                                : scrWidth * 0.35,
                            height: scrHeight * 0.054,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.primaryColor),
                                onPressed: () {
                                  //admin add bool
                                  ref.read(addeventbool.notifier).state =
                                      !addevent;
                                },
                                child: Text(
                                  "Add Event",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                      );
                    })
                  : const SizedBox(),

              // Events list
              Consumer(builder: (context, ref, child) {
                final eventdata = ref.watch(eventsdatastream);

                return eventdata.when(data: (events) {
                  return events.isEmpty
                      ? LottieBuilder.asset(
                          "assets/Animation - 1717412302389.json",
                          height: MediaQuery.of(context).size.height * 0.4,
                        )
                      : LayoutBuilder(builder: (context, constrains) {
                          int crossAxisCount;
                          if (constrains.maxWidth < 600) {
                            crossAxisCount = 1; // Mobile
                          } else {
                            crossAxisCount = 3; // Web/Desktop
                          }

                          return SizedBox(
                            width: double.infinity,
                            child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: events.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: kIsWeb ? 1.0 : 1.4,
                                        //crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                        crossAxisCount: crossAxisCount),
                                itemBuilder: (context, index) {
                                  final data = events[index];

                                  final createdDate = DateFormat("dd-MM-yyyy")
                                      .format(data.createdDate!);
                                  double value = 0;
                                  double target = data.targetamount ?? 0;
                                  if (target > 0) {
                                    value = (data.income ?? 0) / target;
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  EventTransactionsScreen(
                                                    eventModel: data,
                                                  )));
                                    },
                                    child: EventTile(
                                        eventId: data.eventId ?? "",
                                        value: value,
                                        targetAmount: data.targetamount ?? 0,
                                        eventName: data.eventname ?? "",
                                        eventdiscription:
                                            data.discription ?? "",
                                        income: data.income ?? 0,
                                        expense: data.expense ?? 0,
                                        createdDate: createdDate),
                                  );
                                }),
                          );
                        });
                }, error: (Object error, StackTrace stackTrace) {
                  print(stackTrace);
                  return Text(error.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                });
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Version 1.5",
                    style: GoogleFonts.caveat(fontSize: 15),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget eventformfield() {
    return SizedBox(
      width: 400,
      height: 300,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Event Name",
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: eventnameController,
                  decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: "Event name",
                      hintStyle: GoogleFonts.poppins(fontSize: 12),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(color: Colors.black)),
                      filled: true,
                      fillColor: Colors.white),
                )),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: targetamountController,
              decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: "Target Amount",
                  hintStyle: GoogleFonts.poppins(fontSize: 12),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.black)),
                  filled: true,
                  fillColor: Colors.white),
            )),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: TextFormField(
              controller: discriptionController,
              decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  hintText: "Discription",
                  hintStyle: GoogleFonts.poppins(fontSize: 12),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Colors.black)),
                  filled: true,
                  fillColor: Colors.white),
            )),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget addButton({required Function()? onTap, required String title}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xff003F62)),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class EventTile extends StatelessWidget {
  final String eventName;
  final String eventdiscription;
  final double income;
  final double expense;
  double? targetAmount;
  final String createdDate;
  final String eventId;
  double? value;
  EventTile({
    super.key,
    required this.eventName,
    required this.eventdiscription,
    required this.income,
    required this.expense,
    required this.eventId,
    this.value,
    this.targetAmount,
    required this.createdDate,
  });

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade800)),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: SizedBox(
                    width: scrWidth > 600 ? 250 : scrWidth * 0.5,
                    child: Text(
                      eventName.toUpperCase(),
                      style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                isAdmin
                    ? PopupMenuButton<int>(
                        surfaceTintColor: Colors.black,
                        shadowColor: Colors.white,
                        color: Colors.black,
                        tooltip: "",
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.black,
                        ),
                        onSelected: (value) async {
                          if (value == 1) {
                            bool delete = await addDialog(
                                context, "Do you want delete this event?");
                            if (delete) {
                              deleteEvent(eventId, context);
                            }
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                                value: 1,
                                child: Text(
                                  "Delete",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ))
                          ];
                        })
                    : const SizedBox()
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Date",
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffAEAEAE)),
              ),
              Text(
                createdDate,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff478F8F)),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Target Amount",
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffAEAEAE)),
              ),
              Text(
                targetAmount.toString(),
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w400),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Income",
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffAEAEAE)),
              ),
              Text(
                income.toString(),
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffA64658)),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Expense",
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffAEAEAE)),
              ),
              Text(
                expense.toString(),
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.red),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "${((value ?? 0) * 100).toStringAsFixed(1)}%",
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: primarycolor,
                  fontWeight: FontWeight.w400),
            ),
          ),
          LinearProgressIndicator(
            value: value,
            color: primarycolor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          const Spacer()
        ],
      ),
    );
  }
}

void deleteEvent(String eventId, BuildContext context) {
  try {
    FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .update({"delete": true});
    showSnackBar(context, "Event deleted Success");
  } on Exception catch (e) {
    debugPrint(e.toString());
  }
}

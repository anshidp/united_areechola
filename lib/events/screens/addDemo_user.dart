import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/Models/event_transaction_model.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/events/repository/repository.dart';

class AddDemoUser extends StatefulWidget {
  final String eventId;
  const AddDemoUser({super.key, required this.eventId});

  @override
  State<AddDemoUser> createState() => _AddDemoUserState();
}

class _AddDemoUserState extends State<AddDemoUser> {
  final amountController = TextEditingController();
  final usernameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount", style: Theme.of(context).textTheme.titleSmall),
            Padding(padding: EdgeInsets.only(top: 5)),
            SizedBox(
                height: 47,
                width: scrWidth * 0.4,
                child: TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff959FA2))),
                    hintText: "Amount",
                    hintStyle: TextStyle(
                        fontFamily: "PublicSans",
                        fontSize: 12,
                        color: Color(0xff959FA2)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        borderSide: BorderSide(color: Color(0xff959FA2))),
                  ),
                )),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Consumer(builder: (context, ref, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select user",
                  style: Theme.of(context).textTheme.titleSmall),
              Padding(padding: EdgeInsets.only(top: 5)),
              SizedBox(
                height: 47,
                width: scrWidth * 0.4,
                child: TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      enabled: true,
                      hintText: 'Select user',
                      hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: "PublicSans",
                          color: Color(0xff959FA2)),

                      // fillColor: textFormFieldFillColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff959FA2),
                        ),
                        borderRadius: BorderRadius.circular(scrWidth * 0.001),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff959FA2),
                        ),
                        borderRadius: BorderRadius.circular(scrWidth * 0.001),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff959FA2)),
                        borderRadius: BorderRadius.circular(scrWidth * 0.001),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff959FA2)),
                        borderRadius: BorderRadius.circular(scrWidth * 0.001),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff959FA2)),
                        borderRadius: BorderRadius.circular(scrWidth * 0.001),
                      )),
                ),
              )
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
                    usernameController.clear();
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  title: "Cancel"),
              const SizedBox(
                width: 20,
              ),
              Consumer(builder: (context, ref, _) {
                return button(
                    onTap: () async {
                      final eventtransactions = EventTransactionModel(
                          search: search(usernameController.text.trim()),
                          delete: false,
                          amount: double.tryParse(amountController.text),
                          createdDate: DateTime.now(),
                          userId: "",
                          username: usernameController.text.trim(),
                          eventId: widget.eventId);
                      if ((usernameController.text.trim()).isEmpty) {
                        return showSnackBarMsg(context, "Please enter username",Colors.red);
                      }
                      if (amountController.text.isEmpty) {
                        return showSnackBarMsg(context, "Please enter a amount",Colors.red);
                      }
                      bool confirm = await addDialog(
                          context, "Do you want add Transaction?");
                      if (confirm) {
                        ref.read(eventrepositoryProvider).addEventsTransaction(
                            eventTransactionModel: eventtransactions,
                            eventId: widget.eventId ?? "");
                        if (context.mounted) {
                          showSnackBarMsg(
                              context, "Transaction Added successfull",Colors.red);
                        }

                        amountController.clear();
                        usernameController.clear();
                      }
                    },
                    title: "Add Transaction");
              }),
            ],
          ),
        )
      ],
    );
  }

  Widget button({required Function()? onTap, required String title}) {
    double scrWidth = MediaQuery.of(context).size.width;

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
}

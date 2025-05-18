import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/events/repository/repository.dart';

class EventExpensesScreen extends StatefulWidget {
  final String eventId;
  const EventExpensesScreen({super.key, required this.eventId});

  @override
  State<EventExpensesScreen> createState() => _EventExpensesState();
}

class _EventExpensesState extends State<EventExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          children: [
            Consumer(builder: (context, ref, child) {
              return ref.watch(eventExpenseStream(widget.eventId)).when(
                  data: (expenseData) {
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
                    columns: const [
                      DataColumn(
                          label: Text(
                        "No",
                        style: TextStyle(
                            fontFamily: "PublicSans",
                            fontSize: 12,
                            color: Colors.black),
                      )),
                      DataColumn(
                          label: Text("Expense",
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
                    rows: List.generate(expenseData.length, (index) {
                      return DataRow(
                          color:
                              const WidgetStatePropertyAll(Color(0xffFFFFFF)),
                          cells: [
                            DataCell(Text("${index + 1}",
                                style: const TextStyle(
                                    fontFamily: "PublicSans",
                                    fontSize: 13,
                                    color: Colors.black))),
                            DataCell(Text(
                                "${expenseData[index].expenseName?.toUpperCase()}",
                                style: const TextStyle(
                                    fontFamily: "PublicSans",
                                    fontSize: 13,
                                    color: Colors.black))),
                            DataCell(Text("${expenseData[index].amount}",
                                style: const TextStyle(
                                    fontFamily: "PublicSans",
                                    fontSize: 12,
                                    color: Colors.black))),
                          ]);
                    }),
                  ),
                );
              }, error: (Object error, StackTrace stackTrace) {
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
    );
  }
}

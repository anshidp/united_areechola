import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatefulWidget {
  final double totalEventIncome;
  const DashboardChart({super.key, required this.totalEventIncome});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardChartState createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  List<int> weeks = [];
  List<int> years = [];
  TextStyle style = const TextStyle(fontFamily: "PublicSans", fontSize: 13);
  Widget weekTitles(double value, List<int> weeks) {
    try {
      const style = TextStyle(
        fontFamily: "PublicSans",
        fontSize: 13,
      );
      Widget text;
      weeks.sort();
      if (value.toInt() < weeks.length) {
        final week = weeks[value.toInt()];
        text = Text(
          "Week $week",
          style: style,
        );
      } else {
        text = const Text("");
      }
      return text;
    } catch (e) {
      print(e);
      return const SizedBox();
    }
  }

  Widget monthbottomTile(
    double value,
  ) {
    const style = TextStyle(
      fontFamily: "PublicSans",
      fontSize: 8,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Jan', style: style);
        break;
      case 1:
        text = const Text('Feb', style: style);
        break;
      case 2:
        text = const Text('Mar', style: style);
        break;
      case 3:
        text = const Text('Apr', style: style);
        break;
      case 4:
        text = const Text('May', style: style);
        break;
      case 5:
        text = const Text('Jun', style: style);
        break;
      case 6:
        text = const Text('July', style: style);
        break;
      case 7:
        text = const Text('Aug', style: style);
        break;
      case 8:
        text = const Text('Sep', style: style);
        break;
      case 9:
        text = const Text('Oct', style: style);
        break;
      case 10:
        text = const Text('Nov', style: style);
        break;
      case 11:
        text = const Text('Dec', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return text;
  }

  Widget yearTile(double value, List<int> years) {
    const style = TextStyle(
      fontFamily: "Inter",
      fontSize: 10,
    );
    Widget text;
    if (value.toInt() < years.length) {
      final year = years[value.toInt()];
      text = Text(
        year.toString(),
        style: style,
      );
    } else {
      text = const Text("");
    }
    return text;
  }

  final double width = 7;
  List<BarChartGroupData> rawBarGroups = [];
  List<BarChartGroupData> showingBarGroups = [];
  String selectedRange = 'Monthly';

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
    Future.delayed(Duration(seconds: 1)).then(
      (value) {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  // data feching in firebase
  Future<void> fetchDataFromFirestore() async {
    try {
      final eventCollection =
          FirebaseFirestore.instance.collection('transactions');
      final events =
          await eventCollection.where("delete", isEqualTo: false).get();

      List<Map<String, dynamic>> transactions = [];

      for (var transaction in events.docs) {
        transactions.add({
          'start_date': transaction['startDate'].toDate(),
          'amount': transaction['amount'] ?? 0,
        });
      }

      // print("transaction: $transactions");

      if (selectedRange == 'Weekly') {
        processWeeklyData(transactions);
      } else if (selectedRange == 'Monthly') {
        processMonthlyData(transactions);
      } else if (selectedRange == 'Yearly') {
        processYearlyData(transactions);
      }
    } catch (e, s) {
      print(s.toString());
      print(e.toString());
    }
  }

  void processWeeklyData(List<Map<String, dynamic>> transactions) {
    try {
      weeks = [];
      Map<int, double> weeklyData = {};

      for (var transaction in transactions) {
        DateTime date = transaction['date'];
        int weekOfYear = weekNumber(date);

        weeklyData.update(weekOfYear, (value) => value + transaction['amount'],
            ifAbsent: () => transaction['amount']);
      }

      List<BarChartGroupData> barChartGroups = [];
      int index = 0;
      weeklyData.forEach((week, amount) {
        barChartGroups.add(makeGroupData(index, weeklyData[week] ?? 0));
        index++;
        weeks.add(week);
      });
      print("week data : $weeklyData");
      setState(() {
        rawBarGroups = barChartGroups;
        showingBarGroups = rawBarGroups;
      });
    } catch (e, s) {
      print(s.toString());
      print(e.toString());
    }
  }

  // Monthly data

  void processMonthlyData(List<Map<String, dynamic>> transactions) {
    try {
      Map<int, double> monthlyData = {for (int i = 0; i < 12; i++) i: 0.0};
      for (var transaction in transactions) {
        DateTime startDate = transaction['start_date'];

        double amount = transaction['amount'].toDouble() ?? 0.0;

        int month = startDate.month;

        monthlyData[month] = (monthlyData[month] ?? 0) + amount;
      }

      List<BarChartGroupData> barChartGroups = [];
      int index = 0;

      monthlyData.forEach((month, amount) {
        barChartGroups.add(makeGroupData(index, monthlyData[index + 1] ?? 0));
        index++;
      });

      setState(() {
        rawBarGroups = barChartGroups;
        showingBarGroups = rawBarGroups;
      });
    } catch (e,s) {
      print(s.toString());
      print(e);
    }
  }

  void processYearlyData(List<Map<String, dynamic>> transactions) {
    try {
      Map<int, double> yearlyData = {};

      for (var transaction in transactions) {
        DateTime startDate = transaction['start_date'];

        double amount = transaction['amount'].toDouble() ?? 0.0;

        int year = startDate.year;
        yearlyData[year] = (yearlyData[year] ?? 0) + amount;
      }

      List<BarChartGroupData> barChartGroups = [];
      int index = 0;

      yearlyData.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))
        ..forEach((entry) {
          barChartGroups.add(makeGroupData(index, entry.value));
          years.add(entry.key);
          index++;
        });

      setState(() {
        rawBarGroups = barChartGroups;
        showingBarGroups = rawBarGroups;
      });
    } catch (e,s) {
      print(s.toString());
      print("Error in processYearlyData: ${e.toString()}");
    }
  }

  int weekNumber(DateTime date) {
    try {
      final firstDayOfYear = DateTime(date.year, 1, 1);
      final dayOfYear = date.difference(firstDayOfYear).inDays;
      return ((dayOfYear - date.weekday + 10) / 7).floor();
    } catch (e) {
      print(e);
      return 0;
    }
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
  ) {
    return BarChartGroupData(
      barsSpace: 5,
      x: x,
      barRods: [
        BarChartRodData(
          backDrawRodData: BackgroundBarChartRodData(show: true),
          borderRadius: BorderRadius.zero,
          gradient: const LinearGradient(colors: [
            Colors.blue,
            Colors.yellow,
          ]),
          width: 25,
          toY: y,
        ),
      ],
    );
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 100,
                  height: 60,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      autofocus: true,
                      borderRadius: BorderRadius.circular(8),
                      focusColor: Colors.transparent,
                      value: selectedRange,
                      items: ['Monthly', 'Yearly']
                          .map((range) => DropdownMenuItem(
                                value: range,
                                child: Text(
                                  range,
                                  style: const TextStyle(
                                    fontFamily: "PublicSans",
                                    fontSize: 13,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        print("work");
                        setState(() {
                          selectedRange = value!;
                          fetchDataFromFirestore();
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 38,
              ),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue.shade900,
                  ),
                )
              else
                SizedBox(
                  width: double.maxFinite,
                  height: 350,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData:
                              BarTouchTooltipData(getTooltipColor: (bar) {
                            return Colors.white;
                          })),
                      groupsSpace: 3,
                      backgroundColor: Colors.white,
                      maxY: widget.totalEventIncome <= 0
                          ? null
                          : widget.totalEventIncome + 800,
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                            axisNameSize: 18,
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, _) {
                                  List<Widget> tiles = [];
                                  if (selectedRange == "Weekly") {
                                    tiles.add(weekTitles(val, weeks));
                                  } else if (selectedRange == "Monthly") {
                                    tiles.add(monthbottomTile(val));
                                  } else {
                                    tiles.add(yearTile(val, years));
                                  }
                                  return Row(
                                    children: tiles,
                                  );
                                })),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: showingBarGroups,
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

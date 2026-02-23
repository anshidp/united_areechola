import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
    Future.delayed(Duration(seconds: 1)).then(
      (value) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
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
    } catch (e, s) {
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
    } catch (e, s) {
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


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Ultra subtle shadow
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "REVENUE",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Income Trend",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey[700], size: 18),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    focusColor: Colors.transparent,
                    value: selectedRange,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                    items: ['Weekly', 'Monthly', 'Yearly']
                        .map((range) => DropdownMenuItem(
                              value: range,
                              child: Text(range),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRange = value!;
                        fetchDataFromFirestore();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          if (isLoading)
            SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF6366F1),
                  strokeWidth: 2,
                ),
              ),
            )
          else
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 12,
                      tooltipMargin: 16,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      getTooltipColor: (group) => const Color(0xFF1E293B),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toStringAsFixed(0),
                          GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(
                            compactNumber(value),
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (val, meta) {
                          Widget text = const SizedBox();
                          if (selectedRange == "Weekly") {
                            text = weekTitles(val, weeks);
                          } else if (selectedRange == "Monthly") {
                            text = monthbottomTile(val);
                          } else {
                            text = yearTile(val, years);
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: text,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: showingBarGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        (widget.totalEventIncome / 4).clamp(100, 1000000),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[100],
                      strokeWidth: 1,
                    ),
                  ),
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: widget.totalEventIncome * 1.15,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String compactNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}k';
    }
    return number.toStringAsFixed(0);
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF4338CA), // Indigo 700
              Color(0xFF818CF8), // Indigo 400
            ],
          ),
          width: selectedRange == 'Monthly' ? 12 : 20, // Thinner, sleeker bars
          borderRadius: BorderRadius.circular(100), // Fully rounded (stadium)
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: widget.totalEventIncome * 1.15,
            color: const Color(0xFFF1F5F9), // Slate 100
          ),
        ),
      ],
    );
  }
}

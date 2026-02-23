import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SubscriptionReportPage extends StatefulWidget {
  const SubscriptionReportPage({super.key});

  @override
  State<SubscriptionReportPage> createState() => _SubscriptionReportPageState();
}

class _SubscriptionReportPageState extends State<SubscriptionReportPage>
    with SingleTickerProviderStateMixin {
  int selectedYear = DateTime.now().year;
  String searchQuery = '';
  bool isLoading = true;
  List<MemberSubscriptionData> reportData = [];
  
  final List<String> months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  @override
  void initState() {
    super.initState();
    fetchSubscriptionData();
  }

  Future<void> fetchSubscriptionData() async {
    setState(() => isLoading = true);

    try {
      final startDate = DateTime(selectedYear, 1, 1);
      final endDate = DateTime(selectedYear, 12, 31, 23, 59, 59);

      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where("delete", isEqualTo: false)
          .where('startDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<String, MemberSubscriptionData> userDataMap = {};

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final amount = (data['amount'] as num).toDouble();
        final subdate = (data['startDate'] as Timestamp).toDate();
        final month = subdate.month - 1;

        if (!userDataMap.containsKey(userId)) {
          final userDoc = await FirebaseFirestore.instance
              .collection('subcriptionMembers')
              .doc(userId)
              .get();

          final userName = userDoc.exists
              ? (userDoc.data()?['name'] ?? 'Unknown User')
              : 'Unknown User';

          userDataMap[userId] = MemberSubscriptionData(
            userId: userId,
            name: userName,
            monthlyData: List.filled(12, 0.0),
          );
        }

        userDataMap[userId]!.monthlyData[month] += amount;
      }

      if (mounted) {
        setState(() {
          reportData = userDataMap.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<MemberSubscriptionData> get filteredData {
    if (searchQuery.isEmpty) return reportData;
    return reportData.where((member) {
      return member.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  double get grandTotal {
    return filteredData.fold(0.0, (sum, member) => sum + member.yearTotal);
  }

  // Calculate monthly totals for the chart
  List<double> get monthlyTotals {
    if (filteredData.isEmpty) return List.filled(12, 0.0);
    return List.generate(12, (monthIndex) {
      return filteredData.fold(0.0, (sum, member) => sum + member.monthlyData[monthIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Subscription Report",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildYearSelector(),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMembersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedYear,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.indigo[700], size: 18),
          style: GoogleFonts.outfit(
            color: Colors.indigo[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          isDense: true,
          items: List.generate(5, (index) {
            final year = DateTime.now().year - 2 + index;
            return DropdownMenuItem(
              value: year,
              child: Text(year.toString()),
            );
          }),
          onChanged: (year) {
            if (year != null) {
              setState(() => selectedYear = year);
              fetchSubscriptionData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0,4))
          ]
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          style: GoogleFonts.outfit(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search for member...',
            hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }

    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          "No records found",
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final member = filteredData[index];
        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: _buildDetailedMemberCard(member),
        );
      },
    );
  }

  Widget _buildDetailedMemberCard(MemberSubscriptionData member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Total: ₹${member.yearTotal.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Monthly Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, 
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final amount = member.monthlyData[index];
              final isPaid = amount > 0;
              return Container(
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPaid ? Colors.green.shade100 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      months[index],
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPaid ? "${amount.toInt()}" : "-",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isPaid ? Colors.green[700] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MemberSubscriptionData {
  final String userId;
  final String name;
  final List<double> monthlyData;

  MemberSubscriptionData({
    required this.userId,
    required this.name,
    required this.monthlyData,
  });

  double get yearTotal => monthlyData.fold(0.0, (sum, amount) => sum + amount);
}

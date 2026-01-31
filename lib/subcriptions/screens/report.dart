import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  late AnimationController _animationController;

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fetchSubscriptionData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchSubscriptionData() async {
    setState(() => isLoading = true);
    _animationController.reset();

    try {
      final startDate = DateTime(selectedYear, 1, 1);
      final endDate = DateTime(selectedYear, 12, 31, 23, 59, 59);

      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
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

      setState(() {
        reportData = userDataMap.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.purple[50]!,
              Colors.pink[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterSection(),
              SizedBox(height: 40,),
              // _buildStatsCards(),
              Expanded(child: _buildTableSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.purple[400]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.analytics_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Analytics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Track member subscriptions by month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            iconSize: 28,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.grey[400], size: 22),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [],
            ),
            child: DropdownButton<int>(
              value: selectedYear,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.white),
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - 2 + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: const TextStyle(color: Colors.black87),
                  ),
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
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.teal[400]!],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Exporting report...'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Members',
              filteredData.length.toString(),
              Icons.people_rounded,
              [Colors.blue[400]!, Colors.blue[600]!],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total Revenue',
              '\$${NumberFormat('#,###').format(grandTotal)}',
              Icons.attach_money_rounded,
              [Colors.green[400]!, Colors.green[600]!],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Average',
              filteredData.isNotEmpty
                  ? '\$${NumberFormat('#,###').format(grandTotal / filteredData.length)}'
                  : '\$0',
              Icons.trending_up_rounded,
              [Colors.orange[400]!, Colors.orange[600]!],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, List<Color> gradientColors) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading subscription data...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: _buildDataTable(),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      columnSpacing: 44,
      // horizontalMargin: 24,
      // headingRowHeight: 60,
      dataRowHeight: 72,
      headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 2)),
      ),
      columns: [
        DataColumn(
          label: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'MEMBER',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        ...months.map((month) => DataColumn(
              label: Text(
                month.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            )),
        DataColumn(
          label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.purple[400]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TOTAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
      rows: [
        ...filteredData.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (states) => index.isEven ? Colors.grey[50] : Colors.white,
            ),
            cells: [
              DataCell(
                Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[300]!, Colors.purple[300]!],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            member.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              member.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...List.generate(12, (idx) {
                final amount = member.monthlyData[idx];
                return DataCell(
                  Center(
                    child: amount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green[300]!, Colors.teal[400]!],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              amount.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : Text(
                            '—',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 18),
                          ),
                  ),
                );
              }),
              DataCell(
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.purple[500]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      member.yearTotal.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        // Grand Total Row
        DataRow(
          color: WidgetStateProperty.all(Colors.grey[100]),
          cells: [
            const DataCell(
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            ...List.generate(12, (idx) {
              final monthTotal = filteredData.fold(
                0.0,
                (sum, member) => sum + member.monthlyData[idx],
              );
              return DataCell(
                Center(
                  child: monthTotal > 0
                      ? Text(
                          monthTotal.toStringAsFixed(0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : Text(
                          '—',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                ),
              );
            }),
            DataCell(
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[400]!, Colors.red[400]!],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    NumberFormat('#,###').format(grandTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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

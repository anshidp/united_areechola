import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/Models/notification_model.dart';
import 'package:united_areechola/Models/subcription_model.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/subcriptions/repository/repository.dart';
import 'package:united_areechola/subcriptions/screens/report.dart';

class AddSubcription extends ConsumerStatefulWidget {
  const AddSubcription({super.key});

  @override
  ConsumerState<AddSubcription> createState() => _AddSubcriptionState();
}

class _AddSubcriptionState extends ConsumerState<AddSubcription> {
  DateTime? subcriptionStartDate;
  final amountController = TextEditingController();
  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  int unpaidUsers = 0;
  
  // Bulk Subscription State
  bool isBulk = false;
  DateTime? bulkStartDate;
  DateTime? bulkEndDate;

  List<User> userslist = [];
  Map<String, dynamic> users = {};
  List<int> monthlyList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  final dropdownController = TextEditingController();
  final dropdownselectedItem = StateProvider<String?>((ref) => "");
  final dropdownselectedUsername = StateProvider<String?>((ref) => "");
  final dropdownselectedMonth = StateProvider<int?>((ref) => null);
  final addeventbool = StateProvider<bool>((ref) => false);

  Map<String, double> subcriptionamount = {};

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void duplicate() async {
    final members =
        await FirebaseFirestore.instance.collection("subcriptionMembers").get();
    final users = FirebaseFirestore.instance.collection("users");
    for (var user in members.docs) {
      await users.add(user.data());
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    var addevent = ref.watch(addeventbool);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            _buildPageHeader(),
            const SizedBox(height: 14),
            if (isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionReportPage(),
                        ),
                      );
                    },
                    title: 'Subscription Report',
                    isPrimary: true,
                  ),
                ],
              ),
            const SizedBox(height: 14),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildSubscriptionForm(addevent, isTablet),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildUnpaidUsersSection(size)),
                const SizedBox(width: 10),
                Expanded(child: _buildMonthSelector()),
              ],
            ),
            const SizedBox(height: 24),
            _buildTransactionsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Manage Subscriptions",
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Track payments, manage users, and monitor subscription data",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder(
      future: ref
          .read(subcriptionrepositoryprovider)
          .getEachMonthSubscriptionAmount(selectMonth: selectedMonth),
      builder: (context, transactionamount) {
        if (transactionamount.connectionState == ConnectionState.waiting) {
          return _buildStatsLoading();
        }
        if (!transactionamount.hasData) {
          return _buildNoDataCard();
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "This Month",
                value: "${transactionamount.data?["thisMonth"] ?? 0}",
                icon: Icons.calendar_month,
                color: Colors.blue,
                isLoading: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: "Total Amount",
                value: "${transactionamount.data?["total"] ?? 0}",
                icon: Icons.account_balance_wallet,
                color: Colors.green,
                isLoading: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsLoading() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "This Month",
            value: "Loading...",
            icon: Icons.calendar_month,
            color: Colors.blue,
            isLoading: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: "Total Amount",
            value: "Loading...",
            icon: Icons.account_balance_wallet,
            color: Colors.green,
            isLoading: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedFlipCounter(
            fractionDigits: 1,
            prefix: "₹",
            duration: Duration(milliseconds: 100),
            value: double.tryParse(value) ?? 0.0,
            textStyle: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          // Text(
          //   value,
          //   style: GoogleFonts.inter(
          //     fontSize: 24,
          //     fontWeight: FontWeight.w800,
          //     color: Colors.white,
          //   ),
          // ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 48),
            const SizedBox(height: 16),
            Text(
              "No subscription data available",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionForm(bool addevent, bool isTablet) {
    if (addevent) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.person_add, color: Colors.blue[600], size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "Add New Subscription",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Selection Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select User",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropDownTextField(
                    listTextStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    searchTextStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    clearOption: false,
                    enableSearch: true,
                    dropDownList: users.entries
                        .map((e) => DropDownValueModel(
                            name: e.value.toUpperCase(), value: e.key))
                        .toList(),
                    onChanged: (value) {
                      ref.read(dropdownselectedItem.notifier).state =
                          value.value;
                      ref.read(dropdownselectedUsername.notifier).state =
                          value.name;
                    },
                    textFieldDecoration: InputDecoration(
                      hintText: 'Search and select user...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            // Bulk Mode Toggle
            Row(
              children: [
                Checkbox(
                  value: isBulk,
                  onChanged: (value) {
                    setState(() {
                      isBulk = value ?? false;
                    });
                  },
                ),
                Text(
                  "Bulk Subscription (Range)",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isBulk) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From Month",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: bulkStartDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                bulkStartDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  bulkStartDate != null
                                      ? DateFormat('MMM yyyy')
                                          .format(bulkStartDate!)
                                      : "Select",
                                  style: GoogleFonts.inter(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "To Month",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: bulkEndDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                bulkEndDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  bulkEndDate != null
                                      ? DateFormat('MMM yyyy')
                                          .format(bulkEndDate!)
                                      : "Select",
                                  style: GoogleFonts.inter(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Month",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse("$selectedMonth-01"),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _updateSelectedMonth(
                              DateFormat('yyyy-MM').format(picked));
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM yyyy')
                                .format(DateTime.parse("$selectedMonth-01")),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  onTap: () {
                    ref.read(addeventbool.notifier).state = false;
                  },
                  title: 'Cancel',
                  isPrimary: false,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  onTap: () async {
                    await _handleAddSubscription();
                  },
                  title: 'Add Subscription',
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      );
    } else if (isAdmin) {
      return Align(
        alignment: Alignment.centerRight,
        child: _buildActionButton(
          onTap: () {
            ref.read(addeventbool.notifier).state = true;
          },
          title: 'Add Subscription',
          isPrimary: true,
          icon: Icons.add,
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildActionButton({
    required Function()? onTap,
    required String title,
    required bool isPrimary,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isPrimary
            ? LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[800]!],
              )
            : null,
        color: isPrimary ? null : Colors.grey[100],
        border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isPrimary ? Colors.white : Colors.grey[700],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddSubscription() async {
    if ((ref.read(dropdownselectedItem) ?? "").isEmpty) {
      showSnackBarMsg(context, "Please choose a user", Colors.red);
      return;
    }

    if (isBulk) {
      if (bulkStartDate == null || bulkEndDate == null) {
        showSnackBarMsg(context, "Please select both start and end months", Colors.red);
        return;
      }
      if (bulkEndDate!.isBefore(bulkStartDate!)) {
        showSnackBarMsg(context, "End month must be after start month", Colors.red);
        return;
      }

      // Check for existing payments in range
      List<DateTime> monthsInRange = [];
      DateTime current = DateTime(bulkStartDate!.year, bulkStartDate!.month, 1);
      DateTime end = DateTime(bulkEndDate!.year, bulkEndDate!.month, 1);

      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        monthsInRange.add(current);
        current = DateTime(current.year, current.month + 1, 1);
      }

      for (var monthDate in monthsInRange) {
        String monthStr = DateFormat('yyyy-MM').format(monthDate);
        bool? isAlreadyPaid = await ref
            .read(subcriptionrepositoryprovider)
            .isAlreadyPaid(
                userId: ref.read(dropdownselectedItem) ?? "",
                paiddate: monthStr);

        if (isAlreadyPaid != null && isAlreadyPaid) {
          showSnackBarMsg(
              context,
              "${ref.read(dropdownselectedUsername)} is already paid for ${DateFormat('MMM yyyy').format(monthDate)}",
              Colors.red);
          return;
        }
      }

      bool confirm = await addDialog(context, "Add subscription for ${monthsInRange.length} months?");
      
      if (confirm) {
        List<SubcriptionModel> subscriptions = [];
        for (var monthDate in monthsInRange) {
           subscriptions.add(SubcriptionModel(
            startDate: monthDate,
            status: 0,
            createdDate: DateTime.now(),
            delete: false,
            amount: subcriptionAmount,
            userId: ref.read(dropdownselectedItem),
          ));
        }

        await ref
            .read(subcriptionrepositoryprovider)
            .addBulkSubscription(subscriptions: subscriptions);

        showSnackBarMsg(context, "Bulk subscription added successfully", Colors.green);

        // Send Notification
        final username = ref.read(dropdownselectedUsername);
        String startMonthName = DateFormat("MMM yyyy").format(bulkStartDate!);
        String endMonthName = DateFormat("MMM yyyy").format(bulkEndDate!);

        final notification = NotificationModel(
            title: "Bulk Subscription Paid",
            body:
                "${username?.toUpperCase()} has paid ₹${(subcriptionAmount ?? 0) * monthsInRange.length} for $startMonthName to $endMonthName",
            createdDate: DateTime.now(),
            delete: false);

        await ref
            .read(subcriptionrepositoryprovider)
            .addNotificationData(notification);
            
         await ref.read(subcriptionrepositoryprovider).sendNotificationAdmin({
          "title": notification.title,
          "body": notification.body,
        });

        // Reset
        _resetForm();
      }

    } else {
      // Single Subscription
      bool? isAlreadyPaid = await ref
          .read(subcriptionrepositoryprovider)
          .isAlreadyPaid(
              userId: ref.read(dropdownselectedItem) ?? "",
              paiddate: selectedMonth);

      if (isAlreadyPaid != null && isAlreadyPaid) {
        showSnackBarMsg(
            context,
            "${ref.read(dropdownselectedUsername)} is already paid this month",
            Colors.red);
        return;
      }

      bool confirm = await addDialog(context, "Do you want to add subscription?");

      if (confirm) {
        SubcriptionModel subcription = SubcriptionModel(
          startDate: DateTime.parse("$selectedMonth-01"),
          status: 0,
          createdDate: DateTime.now(),
          delete: false,
          amount: subcriptionAmount,
          userId: ref.read(dropdownselectedItem),
        );

        ref
            .read(subcriptionrepositoryprovider)
            .addsubcription(subcriptionModel: subcription);

        showSnackBarMsg(context, "Subscription added successfully", Colors.green);

        final username = ref.read(dropdownselectedUsername);
        final subcriptiondate = DateTime.parse("$selectedMonth-01");
        String monthName = DateFormat("MMMM").format(subcriptiondate);
        String yearName = DateFormat("yyyy").format(subcriptiondate);

        final notification = NotificationModel(
            title: "Subscription Paid",
            body:
                "${username?.toUpperCase()} has paid ₹${subcriptionAmount ?? 0} for the $monthName $yearName subscription",
            createdDate: DateTime.now(),
            delete: false);

        await ref
            .read(subcriptionrepositoryprovider)
            .addNotificationData(notification);

        await ref.read(subcriptionrepositoryprovider).sendNotificationAdmin({
          "title": notification.title,
          "body": notification.body,
        });

        // Clear form
        _resetForm();
      }
    }
  }

  void _resetForm() {
    amountController.clear();
    ref.read(dropdownselectedItem.notifier).state = null;
    ref.read(dropdownselectedMonth.notifier).state = null;
    ref.read(addeventbool.notifier).state = false;
    setState(() {
      isBulk = false;
      bulkStartDate = null;
      bulkEndDate = null;
    });
  }

  Widget _buildUnpaidUsersSection(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder(
        future: ref
            .read(subcriptionrepositoryprovider)
            .getUnpaidUsers(selectedMonth),
        builder: (context, unpaidusers) {
          if (unpaidusers.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!unpaidusers.hasData || unpaidusers.data!.isEmpty) {
            return Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  "All users have paid!",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            );
          }

          unpaidUsers = unpaidusers.data?.length ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.warning, color: Colors.red[600], size: 20),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Unpaid Users",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        "$unpaidUsers users pending",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(maxHeight: size.height * 0.3),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: unpaidusers.data?.length ?? 0,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.red[600],
                            radius: 4,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              unpaidusers.data?[index].toUpperCase() ?? "",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Month",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedMonth != null
                    ? DateTime.parse("$selectedMonth-01")
                    : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF4F46E5), // header color
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                // store only year-month (yyyy-MM)
                final formattedMonth = DateFormat('yyyy-MM').format(pickedDate);

                _updateSelectedMonth(formattedMonth);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedMonth == null
                          ? "Select month"
                          : DateFormat('MMM yyyy')
                              .format(DateTime.parse('$selectedMonth-01')),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final searchController = TextEditingController();

  Widget _buildTransactionsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.receipt_long,
                            color: Colors.green[600], size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Transaction History",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50], // Light background for search
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {}); // Rebuild to filter
                      },
                      decoration: InputDecoration(
                        hintText: "Search by member name...",
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: ref
                  .read(subcriptionrepositoryprovider)
                  .getSubcriptionTransactions(selectedMonth: selectedMonth),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt,
                              color: Colors.grey[400], size: 48),
                          const SizedBox(height: 16),
                          Text(
                            "No transactions found",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Filtering Logic
                final allTransactions = snapshot.data!;
                final filteredTransactions = allTransactions.where((transaction) {
                  final name = users[transaction.userId]?.toString().toLowerCase() ?? "";
                  final searchText = searchController.text.toLowerCase();
                  return name.contains(searchText);
                }).toList();

                if (filteredTransactions.isEmpty) {
                   return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off,
                              color: Colors.grey[400], size: 48),
                          const SizedBox(height: 16),
                          Text(
                            "No results found for \"${searchController.text}\"",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width, 
                    child: DataTable(
                      headingTextStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                      dataTextStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      headingRowColor: WidgetStatePropertyAll(Colors.grey[50]),
                      columns: _buildDataColumns(),
                      rows: _buildDataRows(filteredTransactions),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    if (kIsWeb) {
      return [
        DataColumn(
          label: Text("No",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        DataColumn(
          label: Text("Name",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        DataColumn(
          label: Text("Amount",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        DataColumn(
          label: Text("Date",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        DataColumn(
          label: Text("Status",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        if (isAdmin)
          DataColumn(
            label: Text("Action",
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
      ];
    } else {
      return [
        DataColumn(
          label: Text("No",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        DataColumn(
          label: Text("Name",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        DataColumn(
          label: Text("Amount",
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        if (isAdmin)
          DataColumn(
            label: Text("Action",
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ),
      ];
    }
  }

  List<DataRow> _buildDataRows(List<dynamic> data) {
    return List.generate(data.length, (index) {
      final transaction = data[index];
      return DataRow(
        color: WidgetStatePropertyAll(
          index % 2 == 0 ? Colors.white : Colors.grey[50],
        ),
        cells: [
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${index + 1}",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
          DataCell(
            FutureBuilder(
              future: _fetchUser(transaction?.userId ?? ""),
              builder: (context, username) {
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[100],
                      radius: 12,
                      child: Text(
                        (username.data?.isNotEmpty == true)
                            ? username.data![0].toUpperCase()
                            : "?",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        username.data?.toUpperCase() ?? "Unknown",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "₹${transaction?.amount?.toString() ?? '0'}",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ),
          ),
          if (kIsWeb)
            DataCell(
              Text(
                DateFormat("dd MMM yyyy").format(
                  transaction?.createdDate ?? DateTime.now(),
                ),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          if (kIsWeb)
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Paid",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isAdmin)
            DataCell(
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red[600], size: 18),
                  onPressed: () async {
                    bool delete = await addDialog(
                      context,
                      "Are you sure you want to delete this transaction?",
                    );
                    if (delete) {
                      deleteUser(transId: transaction?.id ?? "");
                      if (context.mounted) {
                        showSnackBarMsg(
                          context,
                          "Transaction deleted successfully",
                          Colors.green,
                        );
                      }
                    }
                  },
                ),
              ),
            ),
        ],
      );
    });
  }

  void deleteUser({required String transId}) {
    try {
      FirebaseFirestore.instance
          .collection("transactions")
          .doc(transId)
          .update({"delete": true});
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
    }
  }

  Widget eventformfield() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        onTap: () async {
          final data = await showDatePicker(
            initialDate: DateTime.now(),
            context: context,
            firstDate: DateTime(2024),
            lastDate: DateTime(2100),
          );
          if (data != null) {
            setState(() {
              subcriptionStartDate = data;
            });
          }
        },
        readOnly: true,
        controller: subcriptionStartDate != null
            ? TextEditingController(
                text: DateFormat("dd-MM-yyyy").format(subcriptionStartDate!))
            : TextEditingController(),
        decoration: InputDecoration(
          hintText: "Start Date",
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// Keep the existing User and Transaction classes
class User {
  final String userId;
  final String username;
  final DateTime createdDate;
  final int amount;

  User({
    required this.createdDate,
    required this.amount,
    required this.userId,
    required this.username,
  });

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

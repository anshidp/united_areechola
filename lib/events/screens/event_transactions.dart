import 'dart:convert';

import 'package:animated_flip_counter/animated_flip_counter.dart';
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
import 'package:united_areechola/events/screens/event_expenses.dart';
import 'package:united_areechola/pdf/services.dart';

import '../../Models/event_transaction_model.dart';

class EventTransactionsScreen extends ConsumerStatefulWidget {
  final EventModel eventModel;
  const EventTransactionsScreen({super.key, required this.eventModel});

  @override
  ConsumerState<EventTransactionsScreen> createState() =>
      _EventTransactionsState();
}

class _EventTransactionsState extends ConsumerState<EventTransactionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic> users = {};
  final amountController = TextEditingController();
  final searchController = TextEditingController();
  final expenseController = TextEditingController();
  final dropdownController = SingleValueDropDownController();
  final isAddTransaction = StateProvider<bool>((ref) => false);
  final isAddExpenses = StateProvider<bool>((ref) => false);
  final dropdownselectedItem = StateProvider<String?>((ref) => "");
  final dropdownselectedUsername = StateProvider<String?>((ref) => "");
  final isDemoUser = StateProvider((ref) => false);
  final usersearch = StateProvider((ref) => "");
  final usernameController = TextEditingController();

  double highestamount = 0;
  String highestPayer = "";

  @override
  void initState() {
    super.initState();
    getUsers();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    amountController.dispose();
    searchController.dispose();
    expenseController.dispose();
    super.dispose();
  }

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_slideAnimation.value * scrWidth, 0),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventHeader(),
                    const SizedBox(height: 24),
                    if (ref.watch(isDemoUser))
                      _buildDemoUserCard()
                    else ...[
                      _buildActionButtons(
                          transaction, expense, scrWidth, scrHeight),
                      const SizedBox(height: 24),
                      if (transaction && isAdmin) _buildTransactionForm(),
                      if (expense && isAdmin) _buildExpenseForm(),
                      _buildStatisticsCards(scrWidth),
                      const SizedBox(height: 24),
                      _buildActionsRow(scrWidth, scrHeight),
                      const SizedBox(height: 24),
                      _buildSearchSection(),
                      const SizedBox(height: 20),
                      _buildTransactionsTable(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Event Transactions',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        if (ref.watch(isAddTransaction) && !ref.watch(isDemoUser))
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => ref.read(isDemoUser.notifier).state = true,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Demo User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_note,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventModel.eventname?.toUpperCase() ?? 'EVENT',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created on ${DateFormat("dd MMM yyyy").format(widget.eventModel.createdDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoUserCard() {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildDemoUserTransactionForm());
  }

  Widget _buildActionButtons(
      bool transaction, bool expense, double scrWidth, double scrHeight) {
    if (transaction || expense || !isAdmin) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            title: 'Add Income',
            icon: Icons.add_circle_outline,
            gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)]),
            onTap: () => ref.read(isAddTransaction.notifier).state = true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            title: 'Add Expense',
            icon: Icons.remove_circle_outline,
            gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
            onTap: () => ref.read(isAddExpenses.notifier).state = true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoUserTransactionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Add Income Transaction",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormField(
            label: "Amount",
            controller: amountController,
            hintText: "Enter amount",
            icon: Icons.monetization_on,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: "Enter User",
            controller: usernameController,
            hintText: "Enter User",
            icon: Icons.monetization_on,
          ),
          const SizedBox(height: 24),
          _buildFormActions(
            primaryTitle: "Add Transaction",
            primaryAction: () async {
              final eventtransactions = EventTransactionModel(
                  search: search(usernameController.text.trim()),
                  delete: false,
                  amount: double.tryParse(amountController.text),
                  createdDate: DateTime.now(),
                  userId: "",
                  username: usernameController.text.trim(),
                  eventId: widget.eventModel.eventId);
              if ((usernameController.text.trim()).isEmpty) {
                return showSnackBarMsg(
                    context, "Please enter username", Colors.red);
              }
              if (amountController.text.isEmpty) {
                return showSnackBarMsg(
                    context, "Please enter a amount", Colors.red);
              }
              bool confirm =
                  await addDialog(context, "Do you want add Transaction?");
              if (confirm) {
                ref.read(eventrepositoryProvider).addEventsTransaction(
                    eventTransactionModel: eventtransactions,
                    eventId: widget.eventModel.eventId ?? "");
                if (context.mounted) {
                  showSnackBarMsg(
                      context, "Transaction Added successfull", Colors.red);
                }

                amountController.clear();
                usernameController.clear();
              }
            },
            secondaryAction: () {
              ref.read(isDemoUser.notifier).state = false;
              ref.read(isAddTransaction.notifier).state = false;
              amountController.clear();
              usernameController.clear();
              cleardropdown();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Add Income Transaction",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormField(
            label: "Amount",
            controller: amountController,
            hintText: "Enter amount",
            icon: Icons.monetization_on,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          _buildUserDropdown(),
          const SizedBox(height: 24),
          _buildFormActions(
            primaryTitle: "Add Transaction",
            primaryAction: () async {
              final eventtransactions = EventTransactionModel(
                search: search(ref.read(dropdownselectedUsername) ?? ""),
                delete: false,
                amount: double.tryParse(amountController.text),
                createdDate: DateTime.now(),
                userId: ref.read(dropdownselectedItem),
                eventId: widget.eventModel.eventId,
              );

              if (((ref.read(dropdownselectedItem) ?? "")).isEmpty) {
                return showSnackBarMsg(
                    context, "Please choose a user", Colors.red);
              }
              if (amountController.text.isEmpty) {
                return showSnackBarMsg(
                    context, "Please enter an amount", Colors.red);
              }

              bool confirm = await addDialog(
                  context, "Do you want to add this transaction?");
              if (confirm) {
                ref.read(eventrepositoryProvider).addEventsTransaction(
                      eventTransactionModel: eventtransactions,
                      eventId: widget.eventModel.eventId ?? "",
                    );
                if (context.mounted) {
                  showSnackBarMsg(
                      context, "Transaction added successfully", Colors.green);
                }
                cleardropdown();
                amountController.clear();
              }
            },
            secondaryAction: () {
              ref.read(isAddTransaction.notifier).state = false;
              amountController.clear();
              cleardropdown();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Add Expense",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormField(
            label: "Expense Name",
            controller: expenseController,
            hintText: "Enter expense description",
            icon: Icons.description,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: "Amount",
            controller: amountController,
            hintText: "Enter amount",
            icon: Icons.monetization_on,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),
          _buildFormActions(
            primaryTitle: "Add Expense",
            primaryAction: () async {
              final eventExpenses = EventExpenseModel(
                expenseName: expenseController.text.trim(),
                amount: double.tryParse(amountController.text),
                createdDate: DateTime.now(),
                userId: ref.read(dropdownselectedItem),
                eventId: widget.eventModel.eventId,
              );

              if (expenseController.text.trim().isEmpty) {
                return showSnackBarMsg(
                    context, 'Please enter expense name', Colors.red);
              }
              if (amountController.text.trim().isEmpty) {
                return showSnackBarMsg(
                    context, 'Please enter amount', Colors.red);
              }

              bool confirm =
                  await addDialog(context, "Do you want to add this expense?");
              if (confirm) {
                ref.read(eventrepositoryProvider).addEventsExpense(
                      eventExpenseModel: eventExpenses,
                      eventId: widget.eventModel.eventId ?? "",
                    );
                if (context.mounted) {
                  showSnackBarMsg(
                      context, "Expense added successfully", Colors.green);
                }
                expenseController.clear();
                amountController.clear();
              }
            },
            secondaryAction: () {
              ref.read(isAddExpenses.notifier).state = false;
              expenseController.clear();
              amountController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: const Color(0xFF667EEA), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(dropdownselectedItem);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select User",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropDownTextField(
              controller: dropdownController,
              clearOption: false,
              enableSearch: true,
              dropDownList: users.entries
                  .map((e) => DropDownValueModel(name: e.value, value: e.key))
                  .toList(),
              onChanged: (value) {
                if (value is DropDownValueModel) {
                  ref.read(dropdownselectedItem.notifier).state = value.value;
                  ref.read(dropdownselectedUsername.notifier).state =
                      value.name;
                } else {
                  ref.read(dropdownselectedItem.notifier).state = null;
                  ref.read(dropdownselectedUsername.notifier).state = null;
                }
              },
              textFieldDecoration: InputDecoration(
                hintText: 'Select user',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.person,
                    color: Color(0xFF667EEA), size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF667EEA), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormActions({
    required String primaryTitle,
    required VoidCallback primaryAction,
    required VoidCallback secondaryAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: secondaryAction,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: primaryAction,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  primaryTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(double scrWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout - stack cards vertically
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                          "Event Name",
                          widget.eventModel.eventname ?? "",
                          const Color(0xFF667EEA),
                          Icons.event)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(
                          "Date",
                          DateFormat("dd-MM-yyyy")
                              .format(widget.eventModel.createdDate!),
                          const Color(0xFFEF4444),
                          Icons.calendar_today)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildIncomeCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildExpenseCard()),
                ],
              ),
            ],
          );
        } else {
          // Desktop layout - all cards in one row
          return Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      "Event Name",
                      widget.eventModel.eventname ?? "",
                      const Color(0xFF667EEA),
                      Icons.event)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatCard(
                      "Date",
                      DateFormat("dd-MM-yyyy")
                          .format(widget.eventModel.createdDate!),
                      const Color(0xFFEF4444),
                      Icons.calendar_today)),
              const SizedBox(width: 16),
              Expanded(child: _buildIncomeCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildExpenseCard()),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return StreamBuilder<double>(
      stream: FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventModel.eventId)
          .snapshots()
          .map((event) => event["totalIncome"].toDouble()),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up,
                    color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                'Income',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedFlipCounter(
                  prefix: "₹",
                  duration: Duration(milliseconds: 1500),
                  value: snapshot.data ?? 0.0,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard() {
    return StreamBuilder<double>(
      stream: FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventModel.eventId)
          .snapshots()
          .map((event) => event["totalexpense"].toDouble()),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            if ((snapshot.data ?? 0) > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventExpensesScreen(
                    eventId: widget.eventModel.eventId ?? "",
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_down,
                      color: Color(0xFFEF4444), size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedFlipCounter(
                  prefix: "₹",
                  duration: Duration(milliseconds: 1500),
                  value: snapshot.data ?? 0.0,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
                // Text(
                //   '₹${snapshot.data?.toStringAsFixed(0) ?? '0'}',
                //   style: const TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xFFEF4444),
                //   ),
                // ),
                if ((snapshot.data ?? 0) > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionsRow(double scrWidth, double scrHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Transactionpdf().downloadPdf(
                  ctx: context,
                  eventName: widget.eventModel.eventname ?? "",
                  eventId: widget.eventModel.eventId ?? "",
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Download PDF",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: scrWidth > 600 ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Search Transactions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: searchController,
            onChanged: (val) => ref.read(usersearch.notifier).state = val,
            decoration: InputDecoration(
              hintText: "Search by user name...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon:
                  const Icon(Icons.search, color: Color(0xFF667EEA), size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable() {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(usersearch);
        Map data = {
          "eventId": widget.eventModel.eventId,
          "search": ref.read(usersearch)
        };

        return ref.watch(eventTransactionStream(jsonEncode(data))).when(
              data: (transactionData) {
                if (transactionData.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Transactions Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Add your first transaction to get started",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667EEA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.list_alt,
                                color: Color(0xFF667EEA),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Transaction History (${transactionData.length})",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          dataTextStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          headingRowColor:
                              WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                          columns: [
                            const DataColumn(
                              label: Text("No."),
                            ),
                            const DataColumn(
                              label: Text("Name"),
                            ),
                            const DataColumn(
                              label: Text("Amount"),
                            ),
                            if (kIsWeb) ...[
                              const DataColumn(
                                label: Text("Date"),
                              ),
                              const DataColumn(
                                label: Text("Actions"),
                              ),
                            ],
                          ],
                          rows: List.generate(transactionData.length, (index) {
                            final transaction = transactionData[index];

                            return DataRow(
                              color: WidgetStateProperty.all(
                                index % 2 == 0
                                    ? Colors.white
                                    : const Color(0xFFF8FAFC),
                              ),
                              cells: [
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF667EEA)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF667EEA),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  transaction.userId == ""
                                      ? Text(
                                          transaction.username ?? "",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )
                                      : FutureBuilder<String>(
                                          future: FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(transaction.userId)
                                              .get()
                                              .then((value) =>
                                                  value.data()?["name"] ??
                                                  "Unknown"),
                                          builder: (context, snapshot) {
                                            return Text(
                                              snapshot.data?.toUpperCase() ??
                                                  "Loading...",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            );
                                          },
                                        ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "₹${transaction.amount?.toStringAsFixed(0) ?? '0'}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ),
                                if (kIsWeb) ...[
                                  DataCell(
                                    Text(
                                      DateFormat("dd MMM yyyy")
                                          .format(transaction.createdDate!),
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFFEF4444),
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          bool delete = await addDialog(
                                            context,
                                            "Are you sure you want to delete this transaction?",
                                          );
                                          if (delete) {
                                            deleteUser(
                                              eventId:
                                                  widget.eventModel.eventId ??
                                                      "",
                                              transId: transaction.id ?? "",
                                            );
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
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              },
              error: (Object error, StackTrace stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade400, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading transactions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
              loading: () => Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                  ),
                ),
              ),
            );
      },
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
}

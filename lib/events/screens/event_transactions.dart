import 'dart:convert';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _EventTransactionsState extends ConsumerState<EventTransactionsScreen> {
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
  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  void dispose() {
    amountController.dispose();
    searchController.dispose();
    expenseController.dispose();
    usernameController.dispose();
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildModernAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: scrWidth > 900 ? 36 : (scrWidth > 600 ? 24 : 16),
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventHeader(scrWidth),
            const SizedBox(height: 20),
            if (ref.watch(isDemoUser))
              _buildDemoUserCard()
            else ...[
              _buildActionButtons(
                  transaction, expense, scrWidth, scrHeight),
              const SizedBox(height: 20),
              if (transaction && isAdmin) _buildTransactionForm(),
              if (expense && isAdmin) _buildExpenseForm(),
              _buildStatisticsCards(scrWidth),
              const SizedBox(height: 20),
              _buildActionsRow(scrWidth, scrHeight),
              const SizedBox(height: 20),
              _buildSearchSection(),
              const SizedBox(height: 20),
              _buildTransactionsTable(),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Event Transactions',
        style: GoogleFonts.poppins(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        if (ref.watch(isAddTransaction) && !ref.watch(isDemoUser))
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => ref.read(isDemoUser.notifier).state = true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Demo User',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildEventHeader(double scrWidth) {
    final double target = widget.eventModel.targetamount ?? 0;
    final createdDateStr = widget.eventModel.createdDate != null
        ? DateFormat("dd MMM yyyy").format(widget.eventModel.createdDate!)
        : 'N/A';

    return Container(
      padding: EdgeInsets.all(scrWidth > 600 ? 24 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventModel.eventname?.toUpperCase() ?? 'EVENT',
                      style: GoogleFonts.poppins(
                        fontSize: scrWidth > 600 ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created on $createdDateStr',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (target > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Target Goal",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        currencyFormatter.format(target),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if ((widget.eventModel.discription ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              widget.eventModel.discription!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDemoUserCard() {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
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
            icon: Icons.add_circle_outline_rounded,
            gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)]),
            onTap: () => ref.read(isAddTransaction.notifier).state = true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildActionButton(
            title: 'Add Expense',
            icon: Icons.remove_circle_outline_rounded,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChips(TextEditingController controller) {
    final presets = [500, 1000, 2500, 5000, 10000];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Amounts",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((val) {
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                double current = double.tryParse(controller.text) ?? 0;
                controller.text = (current + val).toStringAsFixed(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
                ),
                child: Text(
                  "+₹$val",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDemoUserTransactionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Add Income Transaction (Demo User)",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: "Amount",
            controller: amountController,
            hintText: "Enter amount (e.g. 1000)",
            icon: Icons.monetization_on_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          _buildPresetChips(amountController),
          const SizedBox(height: 18),
          _buildFormField(
            label: "Enter User Name",
            controller: usernameController,
            hintText: "Enter User name",
            icon: Icons.person_rounded,
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
                    context, "Please enter an amount", Colors.red);
              }
              bool confirm =
                  await addDialog(context, "Do you want add Transaction?");
              if (confirm) {
                ref.read(eventrepositoryProvider).addEventsTransaction(
                    eventTransactionModel: eventtransactions,
                    eventId: widget.eventModel.eventId ?? "");
                if (context.mounted) {
                  showSnackBarMsg(
                      context, "Transaction Added successfully", Colors.green);
                }

                amountController.clear();
                usernameController.clear();
                ref.read(isDemoUser.notifier).state = false;
                ref.read(isAddTransaction.notifier).state = false;
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_circle_up_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Add Income Contribution",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: "Amount (₹)",
            controller: amountController,
            hintText: "Enter amount",
            icon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          _buildPresetChips(amountController),
          const SizedBox(height: 18),
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
                ref.read(isAddTransaction.notifier).state = false;
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_circle_down_rounded,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Add Event Expense",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: "Expense Item Name",
            controller: expenseController,
            hintText: "e.g. Catering, Venue Rent, Trophies",
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 18),
          _buildFormField(
            label: "Amount (₹)",
            controller: amountController,
            hintText: "Enter expense amount",
            icon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          _buildPresetChips(amountController),
          const SizedBox(height: 24),
          _buildFormActions(
            primaryTitle: "Save Expense",
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
                ref.read(isAddExpenses.notifier).state = false;
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
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade900),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
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
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Text(
              "Select Contributor User",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
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
                hintText: 'Search or select user...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.person_outline_rounded,
                    color: Color(0xFF4F46E5), size: 20),
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
                      const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
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
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
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
        if (constraints.maxWidth < 650) {
          return Column(
            children: [
             
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
          return Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      "Event Name",
                      widget.eventModel.eventname ?? "",
                      const Color(0xFF4F46E5),
                      Icons.event_rounded)),
              const SizedBox(width: 14),
              Expanded(
                  child: _buildStatCard(
                      "Created Date",
                      DateFormat("dd-MM-yyyy")
                          .format(widget.eventModel.createdDate!),
                      const Color(0xFF64748B),
                      Icons.calendar_month_rounded)),
              const SizedBox(width: 14),
              Expanded(child: _buildIncomeCard()),
              const SizedBox(width: 14),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventModel.eventId)
          .collection("Transactions")
          .snapshots(),
      builder: (context, snapshot) {
        double calcIncome = 0;
        if (snapshot.hasData) {
          try {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              // Only include non-deleted transactions
              if (data["delete"] == true) continue;
              final rawAmount = data["amount"];
              if (rawAmount != null) {
                calcIncome += (rawAmount as num).toDouble();
              }
            }
          } catch (e) {
            debugPrint("Error calculating total income: $e");
          }
        }
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'Total Income',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedFlipCounter(
                  prefix: "₹",
                  duration: const Duration(milliseconds: 1000),
                  value: calcIncome,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventModel.eventId)
          .collection("expense")
          .snapshots(),
      builder: (context, snapshot) {
        double calcExpense = 0;
        if (snapshot.hasData) {
          try {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data["delete"] == true) continue;
              final rawExp = data["expenseAmount"];
              if (rawExp != null) {
                calcExpense += (rawExp as num).toDouble();
              }
            }
          } catch (e) {
            debugPrint("Error calculating total expense: $e");
          }
        }
        return GestureDetector(
          onTap: () {
            if (calcExpense > 0) {
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
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
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.trending_down_rounded,
                          color: Color(0xFFEF4444), size: 22),
                    ),
                    if (calcExpense > 0)
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFEF4444)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Total Expenses',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedFlipCounter(
                  prefix: "₹",
                  duration: const Duration(milliseconds: 1000),
                  value: calcExpense,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                if (calcExpense > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view details',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
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
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
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
                    const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Download PDF Report",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: scrWidth > 600 ? 13 : 12,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  color: Color(0xFF4F46E5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Search Transactions",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: searchController,
            onChanged: (val) => ref.read(usersearch.notifier).state = val,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Type user name to filter transactions...",
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Color(0xFF4F46E5), size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Transactions Found",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Add an income transaction above to see it listed here",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
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
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_rounded,
                                    color: Color(0xFF4F46E5),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Transaction History (${transactionData.length})",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                          dataTextStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.grey.shade900,
                          ),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                          ),
                          headingRowColor:
                              WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                          columns: const [
                            DataColumn(
                              label: Text("#"),
                            ),
                            DataColumn(
                              label: Text("Contributor Name"),
                            ),
                            DataColumn(
                              label: Text("Amount"),
                            ),
                            DataColumn(
                              label: Text("Date"),
                            ),
                            DataColumn(
                              label: Text("Actions"),
                            ),
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
                                      color: const Color(0xFF4F46E5)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${index + 1}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: const Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  transaction.userId == ""
                                      ? Text(
                                          transaction.username ?? "",
                                          style: GoogleFonts.poppins(
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
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600),
                                            );
                                          },
                                        ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      currencyFormatter.format(transaction.amount ?? 0),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF059669),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transaction.createdDate != null
                                        ? DateFormat("dd MMM yyyy")
                                            .format(transaction.createdDate!)
                                        : 'N/A',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isAdmin)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Color(0xFF2563EB),
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _showEditTransactionDialog(context, transaction);
                                            },
                                          ),
                                        ),
                                      if (isAdmin)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Color(0xFFDC2626),
                                              size: 18,
                                            ),
                                            onPressed: () async {
                                              bool delete = await addDialog(
                                                context,
                                                "Are you sure you want to delete this transaction?",
                                              );
                                              if (delete) {
                                                await deleteUser(
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
                                    ],
                                  ),
                                ),
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
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: Colors.red.shade400, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading transactions",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.red.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
              loading: () => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  ),
                ),
              ),
            );
      },
    );
  }

  void _showEditTransactionDialog(BuildContext context, EventTransactionModel transaction) {
    final amountCtrl = TextEditingController(
        text: transaction.amount != null ? transaction.amount!.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Edit Income Contribution",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                label: "Amount (₹)",
                controller: amountCtrl,
                hintText: "Enter amount",
                icon: Icons.payments_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () async {
                if (amountCtrl.text.trim().isEmpty) {
                  return showSnackBarMsg(context, "Please enter amount", Colors.red);
                }
                double? newAmount = double.tryParse(amountCtrl.text.trim());
                if (newAmount == null || newAmount <= 0) {
                  return showSnackBarMsg(context, "Please enter a valid amount", Colors.red);
                }
                try {
                  await FirebaseFirestore.instance
                      .collection("events")
                      .doc(widget.eventModel.eventId)
                      .collection("Transactions")
                      .doc(transaction.id)
                      .update({
                    "amount": newAmount,
                  });
                  await syncEventTotals(widget.eventModel.eventId!);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    showSnackBarMsg(context, "Transaction updated successfully", Colors.green);
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              child: Text(
                "Update",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUser({required String eventId, required String transId}) async {
    try {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("Transactions")
          .doc(transId)
          .update({"delete": true});
      await syncEventTotals(eventId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

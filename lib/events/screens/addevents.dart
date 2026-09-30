import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/Models/eventmodel.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/events/repository/repository.dart';
import 'package:united_areechola/events/screens/event_transactions.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFilterProvider = StateProvider<String>((ref) => 'All');

class AddEventsScreen extends ConsumerStatefulWidget {
  const AddEventsScreen({super.key});

  @override
  ConsumerState<AddEventsScreen> createState() => _AddEventsState();
}

class _AddEventsState extends ConsumerState<AddEventsScreen> {
  final addeventbool = StateProvider<bool>((ref) => false);
  final eventnameController = TextEditingController();
  final targetamountController = TextEditingController();
  final discriptionController = TextEditingController();
  final searchController = TextEditingController();

  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void dispose() {
    eventnameController.dispose();
    targetamountController.dispose();
    discriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var addevent = ref.watch(addeventbool);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Finance Dashboard Card (Kuri Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildKuriDashboardCard(),
            ),

            const SizedBox(height: 20),

            // Form toggle or Search Bar
            if (addevent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildEventForm(),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "All Events",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // Events List
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final eventdata = ref.watch(eventsdatastream);

                  return eventdata.when(
                    data: (events) {
                      if (events.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_outlined, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                "No Active Events",
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                        itemCount: events.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final data = events[index];
                          final createdDate = data.createdDate != null
                              ? DateFormat("dd MMM yyyy").format(data.createdDate!)
                              : 'N/A';
                          double target = data.targetamount ?? 0;
                          double income = data.income ?? 0;
                          double expense = data.expense ?? 0;
                          double balance = income - expense;
                          double progress = target > 0 ? (income / target) : 0.0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => EventTransactionsScreen(
                                    eventModel: data,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Header: Full Event Name + Date + Admin Menu (Edit & Delete)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (data.eventname ?? '').toUpperCase(),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                  height: 1.25,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.shade50,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  createdDate,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isAdmin)
                                          PopupMenuButton<int>(
                                            color: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 20),
                                            onSelected: (val) async {
                                              if (val == 1) {
                                                _showEditEventDialog(context, data);
                                              } else if (val == 2) {
                                                bool delete = await addDialog(
                                                  context,
                                                  "Do you want to delete this event?",
                                                );
                                                if (delete) {
                                                  deleteEvent(data.eventId ?? "", context);
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 1,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined, color: Colors.blue.shade600, size: 18),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "Edit",
                                                      style: GoogleFonts.outfit(color: Colors.blue.shade600, fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 2,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 18),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "Delete",
                                                      style: GoogleFonts.outfit(color: Colors.red.shade400, fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    if ((data.discription ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        data.discription!,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 18),
                                    
                                    // Spacious 2x2 Grid for 4 Event Financial Metrics: Target, Income, Expense, Balance
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            _buildGroupStat("Target", currencyFormatter.format(target), Icons.emoji_events_outlined, Colors.amber),
                                            const SizedBox(width: 16),
                                            _buildGroupStat("Income", currencyFormatter.format(income), Icons.trending_up_rounded, Colors.green),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            _buildGroupStat("Expense", currencyFormatter.format(expense), Icons.trending_down_rounded, Colors.red),
                                            const SizedBox(width: 16),
                                            _buildGroupStat("Balance", currencyFormatter.format(balance), Icons.account_balance_wallet_outlined, Colors.indigo),
                                          ],
                                        ),
                                      ],
                                    ),

                                    if (target > 0) ...[
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Progress Goal",
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (progress >= 1.0)
                                                  ? Colors.green.shade50
                                                  : const Color(0xFF6C63FF).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              "${(progress * 100).toStringAsFixed(1)}%",
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: (progress >= 1.0)
                                                    ? Colors.green.shade700
                                                    : const Color(0xFF6C63FF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: progress.clamp(0.0, 1.0),
                                          minHeight: 8,
                                          backgroundColor: Colors.grey.shade100,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            income >= target ? Colors.green : const Color(0xFF6C63FF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                    error: (err, st) => Center(
                      child: Text("Error: $err", style: GoogleFonts.outfit(color: Colors.red)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, EventModel data) {
    final nameCtrl = TextEditingController(text: data.eventname ?? '');
    final targetCtrl = TextEditingController(
        text: data.targetamount != null && data.targetamount! > 0
            ? data.targetamount!.toStringAsFixed(0)
            : '');
    final descCtrl = TextEditingController(text: data.discription ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Edit Event",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKuriTextField("Event Name", nameCtrl, "Enter event title"),
                const SizedBox(height: 12),
                _buildKuriTextField(
                    "Target Amount (₹)", targetCtrl, "Enter target amount",
                    isNumber: true),
                const SizedBox(height: 12),
                _buildKuriTextField(
                    "Description", descCtrl, "Enter description",
                    maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  return showSnackBar(context, "Please enter event name");
                }
                try {
                  await FirebaseFirestore.instance
                      .collection("events")
                      .doc(data.eventId)
                      .update({
                    "eventname": nameCtrl.text.trim(),
                    "targetamount":
                        double.tryParse(targetCtrl.text.trim()) ?? 0,
                    "discription": descCtrl.text.trim(),
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (context.mounted) {
                    showSnackBar(context, "Event updated successfully");
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              child: Text(
                "Update",
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKuriDashboardCard() {
    final eventdata = ref.watch(eventsdatastream);

    return eventdata.when(
      data: (events) {
        double totalTarget = 0;
        double totalIncome = 0;
        double totalExpense = 0;

        for (var e in events) {
          totalTarget += (e.targetamount ?? 0);
          totalIncome += (e.income ?? 0);
          totalExpense += (e.expense ?? 0);
        }

        double totalBalance = totalIncome - totalExpense;
        bool isFormOpen = ref.watch(addeventbool);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Kuri Slate 800-900
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Title + Add Event Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Events Overview",
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${events.length} active events",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    GestureDetector(
                      onTap: () {
                        ref.read(addeventbool.notifier).state = !isFormOpen;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.indigoAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigoAccent.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFormOpen ? Icons.close_rounded : Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFormOpen ? "Close" : "Add Event",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Goal Pill Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Text(
                  "Total Goal Target: ${currencyFormatter.format(totalTarget)}",
                  style: GoogleFonts.outfit(
                    color: Colors.amberAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 14),
              // 3 Finance Metrics Row: Total Income, Total Expense, Net Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKuriDashboardMetric(
                    "Total Income",
                    currencyFormatter.format(totalIncome),
                    Icons.arrow_upward_rounded,
                    Colors.greenAccent,
                  ),
                  Container(width: 1, height: 28, color: Colors.white.withOpacity(0.1)),
                  _buildKuriDashboardMetric(
                    "Total Expense",
                    currencyFormatter.format(totalExpense),
                    Icons.arrow_downward_rounded,
                    const Color(0xFFF87171),
                  ),
                  Container(width: 1, height: 28, color: Colors.white.withOpacity(0.1)),
                  _buildKuriDashboardMetric(
                    "Net Balance",
                    currencyFormatter.format(totalBalance),
                    Icons.account_balance_wallet_rounded,
                    Colors.cyanAccent,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildKuriDashboardMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create New Event",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildKuriTextField("Event Name", eventnameController, "Enter event title"),
          const SizedBox(height: 12),
          _buildKuriTextField("Target Amount", targetamountController, "Enter target amount (₹)", isNumber: true),
          const SizedBox(height: 12),
          _buildKuriTextField("Description", discriptionController, "Enter description (optional)", maxLines: 2),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(addeventbool.notifier).state = false;
                  _clearForm();
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.outfit(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  if (eventnameController.text.trim().isEmpty) {
                    return showSnackBar(context, "Please enter event name");
                  }
                  bool confirm = await addDialog(context, "Do you want to add this event?");
                  if (confirm) {
                    EventModel eventModel = EventModel(
                      delete: false,
                      discription: discriptionController.text.trim(),
                      targetamount: double.tryParse(targetamountController.text.trim()),
                      balance: 0,
                      income: 0,
                      createdDate: DateTime.now(),
                      eventname: eventnameController.text.trim(),
                      users: [],
                      expense: 0,
                    );
                    ref.read(eventrepositoryProvider).addEvents(eventModel);
                    _clearForm();
                    ref.read(addeventbool.notifier).state = false;
                  }
                },
                child: Text(
                  "Create Event",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKuriTextField(String label, TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          maxLines: maxLines,
          style: GoogleFonts.outfit(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _clearForm() {
    eventnameController.clear();
    targetamountController.clear();
    discriptionController.clear();
  }
}

void deleteEvent(String eventId, BuildContext context) {
  try {
    FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .update({"delete": true});
    showSnackBar(context, "Event deleted successfully");
  } on Exception catch (e) {
    debugPrint(e.toString());
  }
}

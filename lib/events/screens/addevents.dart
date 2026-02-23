// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:united_areechola/Models/eventmodel.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/events/repository/repository.dart';
import 'package:united_areechola/events/screens/event_transactions.dart';

class AddEventsScreen extends ConsumerStatefulWidget {
  const AddEventsScreen({super.key});

  @override
  ConsumerState<AddEventsScreen> createState() => _AddEventsState();
}

class _AddEventsState extends ConsumerState<AddEventsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final addeventbool = StateProvider<bool>((ref) => false);
  final eventnameController = TextEditingController();
  final targetamountController = TextEditingController();
  final discriptionController = TextEditingController();

  update() async {
    final data = await FirebaseFirestore.instance.collection("users").get();
    if (data.docs.isNotEmpty) {
      for (var i in data.docs) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(i.id)
            .update({"id": i.id});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    eventnameController.dispose();
    targetamountController.dispose();
    discriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var addevent = ref.watch(addeventbool);
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_slideAnimation.value * scrWidth, 0),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: scrWidth > 600 ? 40 : 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    _buildHeader(scrWidth, scrHeight, addevent),
                    if (addevent) ...[
                      const SizedBox(height: 24),
                      _buildEventForm(),
                    ],
                    const SizedBox(height: 32),
                    _buildEventsGrid(scrWidth),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(double scrWidth, double scrHeight, bool addevent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Event Management",
                  style: GoogleFonts.poppins(
                    fontSize: scrWidth > 600 ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create and manage your events efficiently",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (!addevent && isAdmin) _buildAddEventButton(),
        ],
      ),
    );
  }

  Widget _buildAddEventButton() {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(addeventbool.notifier).state = true;
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add Event",
                      style: GoogleFonts.poppins(
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
        );
      },
    );
  }

  Widget _buildEventForm() {
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
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: Color(0xFF667EEA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Create New Event",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormField(
            label: "Event Name",
            controller: eventnameController,
            hintText: "Enter event name",
            icon: Icons.title,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: "Target Amount",
            controller: targetamountController,
            hintText: "Enter target amount",
            icon: Icons.monetization_on,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          _buildFormField(
            label: "Description",
            controller: discriptionController,
            hintText: "Enter event description",
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                title: 'Cancel',
                onTap: () {
                  ref.read(addeventbool.notifier).state = false;
                  _clearForm();
                },
                isSecondary: true,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                title: 'Add Event',
                onTap: () async {
                  if (eventnameController.text.isEmpty) {
                    return showSnackBar(context, "Please enter the event name");
                  }

                  bool confirm = await addDialog(
                      context, "Do you want to add this event?");

                  if (confirm) {
                    EventModel eventModel = EventModel(
                      delete: false,
                      discription: discriptionController.text,
                      targetamount:
                          double.tryParse(targetamountController.text),
                      balance: 0,
                      income: 0,
                      createdDate: DateTime.now(),
                      eventname: eventnameController.text,
                      users: [],
                      expense: 0,
                    );
                    ref.read(eventrepositoryProvider).addEvents(eventModel);
                    _clearForm();
                  }
                  ref.read(addeventbool.notifier).state = false;
                },
              ),
            ],
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
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
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

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSecondary
            ? null
            : const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
        borderRadius: BorderRadius.circular(12),
        border: isSecondary ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Material(
        color: isSecondary ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSecondary ? Colors.grey.shade700 : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsGrid(double scrWidth) {
    return Consumer(
      builder: (context, ref, child) {
        final eventdata = ref.watch(eventsdatastream);

        return eventdata.when(
          data: (events) {
            if (events.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    LottieBuilder.asset(
                      "assets/Animation - 1717412302389.json",
                      height: 200,
                    ),
                    Text(
                      "No Events Yet",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create your first event to get started",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth < 1200) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: events.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: kIsWeb ? 1.1 : 1.3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    crossAxisCount: crossAxisCount,
                  ),
                  itemBuilder: (context, index) {
                    final data = events[index];
                    final createdDate =
                        DateFormat("dd-MM-yyyy").format(data.createdDate!);
                    double value = 0;
                    double target = data.targetamount ?? 0;
                    if (target > 0) {
                      value = (data.income ?? 0) / target;
                    }

                    return ModernEventTile(
                      eventId: data.eventId ?? "",
                      value: value,
                      targetAmount: data.targetamount ?? 0,
                      eventName: data.eventname ?? "",
                      eventDescription: data.discription ?? "",
                      income: data.income ?? 0,
                      expense: data.expense ?? 0,
                      createdDate: createdDate,
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
                    );
                  },
                );
              },
            );
          },
          error: (Object error, StackTrace stackTrace) {
            return Container(
              padding: const EdgeInsets.all(24),
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
                    "Error loading events",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: GoogleFonts.poppins(
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            "Version 2.7",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    eventnameController.clear();
    targetamountController.clear();
    discriptionController.clear();
  }
}

class ModernEventTile extends StatelessWidget {
  final String eventName;
  final String eventDescription;
  final double income;
  final double expense;
  final double targetAmount;
  final String createdDate;
  final String eventId;
  final double value;
  final VoidCallback onTap;

  const ModernEventTile({
    super.key,
    required this.eventName,
    required this.eventDescription,
    required this.income,
    required this.expense,
    required this.eventId,
    required this.value,
    required this.targetAmount,
    required this.createdDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildEventName(),
                const SizedBox(height: 12),
                _buildFinancialInfo(),
                const Spacer(),
                _buildProgressSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            createdDate,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667EEA),
            ),
          ),
        ),
        if (isAdmin)
          PopupMenuButton<int>(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey.shade600,
              size: 20,
            ),
            onSelected: (value) async {
              if (value == 1) {
                bool delete = await addDialog(
                  context,
                  "Do you want to delete this event?",
                );
                if (delete) {
                  deleteEvent(eventId, context);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Delete",
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEventName() {
    return Text(
      eventName.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFinancialInfo() {
    return Column(
      children: [
        _buildInfoRow("Target", "₹${targetAmount.toStringAsFixed(0)}",
            Colors.blue.shade600),
        const SizedBox(height: 8),
        _buildInfoRow(
            "Income", "₹${income.toStringAsFixed(0)}", Colors.green.shade600),
        const SizedBox(height: 8),
        _buildInfoRow(
            "Expense", "₹${expense.toStringAsFixed(0)}", Colors.red.shade600),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progress",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              "${(value * 100).toStringAsFixed(1)}%",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667EEA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
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

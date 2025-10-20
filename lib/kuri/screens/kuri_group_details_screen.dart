import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/Models/kuri_group.dart';
import 'package:united_areechola/Models/kuri_member.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/kuri/repository/kuri_repository.dart';
import 'package:united_areechola/kuri/screens/kuri_member_adding_screen.dart';
import 'package:united_areechola/kuri/screens/kuri_spinwheel_screen.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KuriGroup?>(
      stream: ref.read(kurirepositoryProvider).getKuriGroup(widget.groupId),
      builder: (context, groupSnapshot) {
        if (!groupSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final group = groupSnapshot.data!;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            group.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: StreamBuilder<List<KuriMember>>(
                        stream: ref
                            .read(kurirepositoryProvider)
                            .getMembers(group.id ?? ""),
                        builder: (context, membersSnapshot) {
                          final members = membersSnapshot.data ?? [];

                          return ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              // Stats Cards
                              FadeInUp(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF6584),
                                              Color(0xFFFF4F6D)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF6584)
                                                  .withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.emoji_events,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '₹${group.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Monthly Prize',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6C63FF),
                                              Color(0xFF5A52D5)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF6C63FF)
                                                  .withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${group.currentMonth}/${group.totalMembers}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Current Month',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Progress Bar
                              FadeInUp(
                                delay: const Duration(milliseconds: 200),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Progress',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${((group.currentMonth / group.totalMembers) * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6C63FF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: group.currentMonth /
                                              group.totalMembers,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(
                                            Color(0xFF6C63FF),
                                          ),
                                          minHeight: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Spin Button
                              if (members.length == group.totalMembers &&
                                  group.currentMonth != group.totalMembers &&
                                  isAdmin)
                                FadeInUp(
                                  delay: const Duration(milliseconds: 300),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700)
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        bool spinAvailableThisday = ref
                                            .read(kurirepositoryProvider)
                                            .isSpinAvailability(
                                                group.lastSpinDate);
                                        if (!spinAvailableThisday) {
                                          final nextSpindate = DateTime(
                                            group.lastSpinDate!.year,
                                            group.lastSpinDate!.month + 1,
                                            group.lastSpinDate!.day,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.close,
                                                      color: Colors.white),
                                                  SizedBox(width: 12),
                                                  Text(
                                                      'You can only spin on ${DateFormat('dd-MMMM-yyyy').format(nextSpindate)}'),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          );
                                          return;
                                        }
                                        bool isLastwinner =
                                            (group.totalMembers -
                                                    group.currentMonth) ==
                                                1;

                                        final nextMonth =
                                            (group.currentMonth) + 1;
                                        final winner = await ref
                                            .read(kurirepositoryProvider)
                                            .getLastWinner(
                                                groupId: widget.groupId);
                                        if (isLastwinner) {
                                          await ref
                                              .read(kurirepositoryProvider)
                                              .updateWinner(
                                                widget.groupId,
                                                nextMonth,
                                                winner.id ?? "",
                                              )
                                              .then(
                                                (value) =>
                                                    Navigator.pop(context),
                                              );
                                        }
                                        final eligibleMembers = await ref
                                            .read(kurirepositoryProvider)
                                            .getEligibleMembers(widget.groupId);
                                        if (eligibleMembers.length <= 1) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(Icons.close_rounded,
                                                      color: Colors.white),
                                                  SizedBox(width: 12),
                                                  Text(
                                                      'Members must be greater than 1'),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                KuriSpinWheelScreen(
                                                    groupId: widget.groupId),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.casino,
                                              color: Colors.white, size: 28),
                                          SizedBox(width: 12),
                                          Text(
                                            (group.totalMembers -
                                                        group.currentMonth) ==
                                                    1
                                                ? "Update the Last winner"
                                                : "Spin the wheel",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),

                              // Members Section
                              const Text(
                                'Members',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (members.isEmpty)
                                FadeIn(
                                  child: Container(
                                    padding: const EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.person_add,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No members yet',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...(() {
                                  final sortedMembers = [...members];
                                  sortedMembers.sort((a, b) {
                                    final aMonth = a.wonMonth;
                                    final bMonth = b.wonMonth;
                                    return bMonth.compareTo(aMonth);
                                  });
                                  return sortedMembers
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final member = entry.value;
                                    return FadeInUp(
                                      delay:
                                          Duration(milliseconds: 100 * index),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: member.wonMonth > 0
                                                    ? [
                                                        const Color(0xFFFFD700),
                                                        const Color(0xFFFFA500)
                                                      ]
                                                    : [
                                                        const Color(0xFF6C63FF),
                                                        const Color(0xFF5A52D5)
                                                      ],
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                member.name[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            member.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: Text(
                                            member.phone,
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                          trailing: member.wonMonth > 0
                                              ? Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFFFFD700),
                                                        Color(0xFFFFA500),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.emoji_events,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'M${member.wonMonth}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF6C63FF)
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: const Text(
                                                    'Active',
                                                    style: TextStyle(
                                                      color: Color(0xFF6C63FF),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                })(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: group.memberIds.length < group.totalMembers &&
                  isAdmin
              ? FadeInUp(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddMemberScreen(groupId: widget.groupId),
                          ),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        'Add Member',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

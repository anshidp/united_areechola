import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/Models/bloodgroup_model.dart';
import 'package:united_areechola/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodGroups extends StatefulWidget {
  const BloodGroups({super.key});

  @override
  State<BloodGroups> createState() => _BloodGroupsState();
}

class _BloodGroupsState extends State<BloodGroups>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<String> bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
  String? bloodGroup;
  bool isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  makingPhoneCall(String phoneNumber) async {
    try {
      var url = Uri.parse("tel:$phoneNumber");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call to $phoneNumber'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error making phone call'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Color _getBloodGroupColor(String? bloodGroup) {
    switch (bloodGroup) {
      case 'A+':
      case 'A-':
        return Colors.red[600]!;
      case 'B+':
      case 'B-':
        return Colors.blue[600]!;
      case 'AB+':
      case 'AB-':
        return Colors.purple[600]!;
      case 'O+':
      case 'O-':
        return Colors.green[600]!;
      default:
        return Colors.red[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Find Blood Donors',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: primarycolor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: primarycolor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header Section with Statistics
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primarycolor, primarycolor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primarycolor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Row(
                //   children: [
                //     Container(
                //       padding: const EdgeInsets.all(16),
                //       decoration: BoxDecoration(
                //         color: Colors.white.withOpacity(0.2),
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //       child: const Icon(
                //         Icons.bloodtype_rounded,
                //         color: Colors.white,
                //         size: 32,
                //       ),
                //     ),
                //     const SizedBox(width: 16),
                //     Expanded(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             'Blood Donation Network',
                //             style: GoogleFonts.poppins(
                //               fontSize: 20,
                //               fontWeight: FontWeight.w600,
                //               color: Colors.white,
                //             ),
                //           ),
                //           const SizedBox(height: 4),
                //           Text(
                //             'Connect with donors in your area',
                //             style: GoogleFonts.poppins(
                //               fontSize: 14,
                //               color: Colors.white.withOpacity(0.9),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                 
                //   ],
                // ),
                // const SizedBox(height: 20),
                _buildBloodGroupFilter(),
              ],
            ),
          ),

          // Donors List
          Expanded(
            child: _buildDonorsList(size),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Blood Group',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // Blood Group Pills
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bloodGroups.map((group) {
            final isSelected = bloodGroup == group;
            return GestureDetector(
              onTap: () {
                setState(() {
                  bloodGroup = isSelected ? null : group;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getBloodGroupColor(group)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      group,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primarycolor : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        if (bloodGroup != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                bloodGroup = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Clear Filter',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDonorsList(Size size) {
    return StreamBuilder<List<BloodGroup>>(
      stream: bloodGroup == null
          ? FirebaseFirestore.instance
              .collection("bloodGroups")
              .snapshots()
              .map((event) =>
                  event.docs.map((e) => BloodGroup.fromMap(e.data())).toList())
          : FirebaseFirestore.instance
              .collection("bloodGroups")
              .where("bloodGroup", isEqualTo: bloodGroup)
              .snapshots()
              .map((event) =>
                  event.docs.map((e) => BloodGroup.fromMap(e.data())).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || (snapshot.data ?? []).isEmpty) {
          return _buildEmptyState();
        }

        final donors = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.people_rounded, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${donors.length} Donor${donors.length == 1 ? '' : 's'} Available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildDonorCard(donors[index], index),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonorCard(BloodGroup donor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Blood Group Avatar
          Hero(
            tag: 'donor_${donor.name}_$index',
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getBloodGroupColor(donor.bloodGroup),
                    _getBloodGroupColor(donor.bloodGroup).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        _getBloodGroupColor(donor.bloodGroup).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  donor.bloodGroup ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Donor Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.name?.toUpperCase() ?? "Unknown Donor",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      donor.phoneNumber ?? "No phone number",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // Call Button
          GestureDetector(
            onTap: () {
              if (donor.phoneNumber?.isNotEmpty == true) {
                makingPhoneCall(donor.phoneNumber!);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[500]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Call',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              bloodGroup != null
                  ? 'No donors found for $bloodGroup'
                  : 'No donors available',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bloodGroup != null
                  ? 'Try selecting a different blood group or clear the filter'
                  : 'Check back later for available donors',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (bloodGroup != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    bloodGroup = null;
                  });
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filter'),
                style: TextButton.styleFrom(
                  foregroundColor: primarycolor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

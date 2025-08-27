import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:united_areechola/Models/usermodel.dart';
import 'package:united_areechola/addUser/controller/controller.dart';
import 'package:united_areechola/addUser/repository/repository.dart';
import 'package:united_areechola/constants.dart';

class AddUsers extends ConsumerStatefulWidget {
  const AddUsers({super.key});

  @override
  ConsumerState<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends ConsumerState<AddUsers>
    with TickerProviderStateMixin {
  final searchAdminProvider = StateProvider((ref) => "");
  String selectedCountryCode = '';
  ScrollController scrollController = ScrollController();
  final addAdminBool = StateProvider((ref) => false);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  String selectedGroup = "A+";
  String? downloadUrl;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    scrollController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    searchController.dispose();
    ageController.dispose();
    super.dispose();
  }

  createUser(addAdmin) {
    Usermodel usermodel = Usermodel(
        age: int.tryParse(ageController.text),
        createdDate: DateTime.now(),
        delete: false,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        bloodGroup: selectedGroup,
        search: search(
            "${nameController.text.trim()} ${emailController.text.trim()} $selectedGroup"));

    ref.read(adduserRepositoryProvider).addUser(usermodel).then((value) {
      _clearControllers();
      ref.read(addAdminBool.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  void _clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneNumberController.clear();
    ageController.clear();
    downloadUrl = '';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var addAdmin = ref.watch(addAdminBool);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'User Management',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: MyColors.primaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!addAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => ref.read(addAdminBool.notifier).state = true,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add User'),
                style: FilledButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Add User Form
            if (addAdmin) _buildAddUserForm(size),

            if (addAdmin) const SizedBox(height: 32),

            // Search Section
            if (!addAdmin) _buildSearchSection(size),

            const SizedBox(height: 24),

            // Users List
            _buildUsersList(size),
          ],
        ),
      ),
    );
  }

  Widget _buildAddUserForm(Size size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MyColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_add_rounded,
                        color: MyColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Add New User',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Name and Phone Row
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            'Name', nameController, Icons.person_outline)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPhoneField()),
                  ],
                ),

                const SizedBox(height: 20),

                // Email and Age Row
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField('Email (Optional)',
                            emailController, Icons.email_outlined,
                            isRequired: false)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField('Age (Optional)', ageController,
                            Icons.cake_outlined,
                            isRequired: false, isNumber: true)),
                  ],
                ),

                const SizedBox(height: 20),

                // Blood Group Dropdown
                _buildBloodGroupDropdown(),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        ref.read(addAdminBool.notifier).state = false;
                        _clearControllers();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _validateAndSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: MyColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add User',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isRequired = true, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          maxLength: (label.contains('Age') && isNumber) ? 2 : null,
          decoration: InputDecoration(
            hintText: 'Enter ${label.toLowerCase()}',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: MyColors.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: phoneNumberController,
          decoration: InputDecoration(
            hintText: 'Enter phone number',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: MyColors.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          initialCountryCode: 'IN',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (phone) {
            selectedCountryCode = phone.countryCode;
          },
        ),
      ],
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Group',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedGroup,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.bloodtype_rounded, color: Colors.red[400]),
            ),
            items: bloodGroups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(
                  group,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedGroup = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(Size size) {
    return Container(
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
          Icon(Icons.search_rounded, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                ref.read(searchAdminProvider.notifier).state =
                    value.toUpperCase().trim();
              },
              decoration: InputDecoration(
                hintText: 'Search by name or blood group...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clear();
                ref.read(searchAdminProvider.notifier).state = '';
              },
              icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
            ),
        ],
      ),
    );
  }

  Widget _buildUsersList(Size size) {
    return Consumer(
      builder: (context, ref, child) {
        return ref
            .watch(getuserStreamprovider(ref.watch(searchAdminProvider)))
            .when(
              data: (userSnapshot) {
                if (userSnapshot.isEmpty) {
                  return Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort users logic (same as original)
                final firstList = userSnapshot
                    .where((user) =>
                        user.phoneNumber != "0000000000" &&
                        (user.email ?? "").isNotEmpty)
                    .toList();
                final noEmailList = userSnapshot
                    .where((user) =>
                        user.phoneNumber != "0000000000" &&
                        (user.email ?? "").isEmpty)
                    .toList();
                final secondList = userSnapshot
                    .where((user) => user.phoneNumber == "0000000000")
                    .toList();
                final combinedList = [
                  ...firstList,
                  ...noEmailList,
                  ...secondList
                ];

                return Container(
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
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: MyColors.primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              'Users (${combinedList.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Users List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: combinedList.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          final user = combinedList[index];
                          return _buildUserTile(user, index);
                        },
                      ),
                    ],
                  ),
                );
              },
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error loading users',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
      },
    );
  }

  Widget _buildUserTile(Usermodel user, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: MyColors.primaryColor.withOpacity(0.1),
            child: Text(
              (user.name?.isNotEmpty == true)
                  ? user.name![0].toUpperCase()
                  : 'U',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: MyColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Unknown User',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                if (user.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.email!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      user.phoneNumber ?? 'No phone',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.bloodGroup ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: () => deleteShowDialogue(user),
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400]),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndSubmit() {
    RegExp phnChk = RegExp(r'^\+?\d{10}$');

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter name'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (!phnChk.hasMatch(phoneNumberController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid phone number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    addDialog(context, ref.watch(addAdminBool));
  }

  // Delete dialog
  deleteShowDialogue(Usermodel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Text(
              'Confirm Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () {
              deleteAdmin(user);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('User deleted successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child:
                Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add user confirmation dialog
  Future<void> addDialog(BuildContext context, addadmin) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_add_rounded, color: MyColors.primaryColor),
            const SizedBox(width: 12),
            Text(
              'Confirm Add User',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to add this user?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () {
              createUser(addAdminBool);
              Navigator.pop(context);
            },
            style:
                FilledButton.styleFrom(backgroundColor: MyColors.primaryColor),
            child: Text('Add User',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void deleteAdmin(Usermodel user) {
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .update({'delete': true});
    } catch (e) {
      throw e.toString();
    }
  }
}

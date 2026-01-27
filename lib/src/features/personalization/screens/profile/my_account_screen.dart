import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:quickalert/quickalert.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:aaliyahs_collection_estore/src/features/authentication/providers/auth_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/widgets/edit_profile_image_picker.dart';

import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/widgets/auth_text_field.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: _buildAppBar(context, isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: TUIConstants.horizontalPadding * 1.5, 
          vertical: TUIConstants.verticalPadding
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              EditProfileImagePicker(
                localImageFile: _imageFile,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: 48),
              _buildFields(isDarkMode),
              const SizedBox(height: 32),
              _buildActionButton(),
              const SizedBox(height: 16),
              _buildDeleteButton(userProvider),
              const SizedBox(height: 32),
              _buildFooter(userProvider),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
      ),
      title: Text(
        "Edit Profile",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
    );
  }

  Widget _buildFields(bool isDarkMode) {
    return Column(
      children: [
        AuthTextField(controller: _firstNameController, label: "First Name", prefixIcon: Icons.person_outline),
        const SizedBox(height: 20),
        AuthTextField(controller: _lastNameController, label: "Last Name", prefixIcon: Icons.person_outline),
        const SizedBox(height: 20),
        AuthTextField(controller: _usernameController, label: "Username", prefixIcon: Icons.alternate_email),
        const SizedBox(height: 20),
        AuthTextField(controller: _emailController, label: "E-Mail", prefixIcon: Icons.email_outlined),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleUpdateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: aaliyahPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
        ),
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
          : const Text("UPDATE PROFILE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildFooter(UserProvider userProvider) {
    return Center(
      child: Text(
        "Joined: ${_formatDate(userProvider.user?.createdAt)}",
        style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Unknown';
    try {
      final DateTime date = DateTime.parse(dateStr);
      // Manual formatting since intl might not be installed or configured
      // Format: 31 October 2022
      const List<String> months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      // Return original if parsing fails (fallback)
      return dateStr;
    }
  }

  Widget _buildDeleteButton(UserProvider userProvider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showDeleteConfirmation(userProvider),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text("DELETE ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _handleUpdateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      setState(() => _isLoading = false);
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text("Profile Updated"),
          description: const Text("Your changes have been saved successfully."),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _showDeleteConfirmation(UserProvider userProvider) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Delete Account',
      text: 'This action is permanent. Are you sure?',
      confirmBtnText: 'Delete',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        final result = await userProvider.deleteAccount();
        if (!mounted) return;
        if (result['status'] == 'success') {
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
    );
  }
}

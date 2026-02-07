import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/widgets/edit_profile_image_picker.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';

import 'package:aaliyahs_collection_estore/common/widgets/form/auth_text_field.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_loader.dart';

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
  DateTime? _selectedDob;
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserController>(context, listen: false).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _selectedDob = user?.dob != null ? DateTime.tryParse(user!.dob!) : null;
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
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: _buildAppBar(context, isDarkMode),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
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
                  _buildDeleteButton(userController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AaliyahSmallAppBar(
      title: 'Edit profile',
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFields(bool isDarkMode) {
    return Column(
      children: [
        AuthTextField(
            controller: _firstNameController,
            label: 'First name',
            prefixIcon: Icons.person_outline,
            isOutlined: true),
        const SizedBox(height: 20),
        AuthTextField(
            controller: _lastNameController,
            label: 'Last name',
            prefixIcon: Icons.person_outline,
            isOutlined: true),
        const SizedBox(height: 20),
        AuthTextField(
            controller: _usernameController,
            label: 'Username',
            prefixIcon: Icons.alternate_email,
            isOutlined: true),
        const SizedBox(height: 20),
        AuthTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            isOutlined: true),
      ],
    );
  }



  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isLoading ? null : _handleUpdateProfile,
        child: _isLoading 
          ? const Center(child: ExpressiveLoader(size: 24, color: Colors.white, semanticLabel: 'Updating profile...')) 
          : const Text('Update profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }



  Widget _buildDeleteButton(UserController userController) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showDeleteConfirmation(userController),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Delete account', style: TextStyle(fontWeight: FontWeight.bold)),
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
      
      final userController = Provider.of<UserController>(context, listen: false);
      await userController.updateUserProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        dob: _selectedDob?.toIso8601String(),
        image: _imageFile,
      );

      setState(() => _isLoading = false);
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text('Profile updated'),
          description: const Text('Changes saved'),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _showDeleteConfirmation(UserController userController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This action is permanent. All your data, orders, and preferences will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final authController = Provider.of<AuthController>(context, listen: false);
              final navigator = Navigator.of(this.context); // Use state context for navigation
              Navigator.pop(context); // Close dialog
              final result = await userController.deleteAccount();
              if (!mounted) return;
              if (result['status'] == 'success') {
                authController.logout();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

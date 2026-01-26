import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
        ),
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Profile Image Section
              _buildProfileImagePicker(context, isDarkMode, userProvider),
              const SizedBox(height: 40),

              // 2. Input Fields (Modern Styled)
              _buildModernTextField("First Name", _firstNameController, Icons.person_outline, isDarkMode),
              const SizedBox(height: 20),
              _buildModernTextField("Last Name", _lastNameController, Icons.person_outline, isDarkMode),
              const SizedBox(height: 20),
              _buildModernTextField("Username", _usernameController, Icons.alternate_email, isDarkMode),
              const SizedBox(height: 20),
              _buildModernTextField("E-Mail", _emailController, Icons.email_outlined, isDarkMode),
              
              const SizedBox(height: 40),

              // 3. Main Action Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aaliyahPrimaryColor, // Maroon
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 30),

              // 4. Footer Info & Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      children: const [
                        TextSpan(text: "Joined ", style: TextStyle(color: Colors.black)),
                        TextSpan(text: "31 October 2022", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
                  ),
                  _buildDeleteBtn(userProvider),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker(BuildContext context, bool isDarkMode, UserProvider userProvider) {
    final user = userProvider.user;
    final hasProfileImg = user != null && user.profilePhotoUrl.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : (hasProfileImg
                    ? CachedNetworkImage(
                        imageUrl: user.profilePhotoUrl,
                        fit: BoxFit.cover,
                        httpHeaders: userProvider.token != null ? {'Authorization': 'Bearer ${userProvider.token}'} : null,
                      )
                    : Image.asset(aaliyahProfileImage, fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: aaliyahPrimaryColor, // Maroon
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    bool isDarkMode, 
    {bool isPassword = false, bool obscureText = false, VoidCallback? onSuffixTap}
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: aaliyahPrimaryColor, fontSize: 14),
        prefixIcon: Icon(icon, color: aaliyahPrimaryColor, size: 20),
        suffixIcon: isPassword 
          ? GestureDetector(onTap: onSuffixTap, child: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey))
          : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: aaliyahPrimaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDeleteBtn(UserProvider userProvider) {
    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context, userProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Delete",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Future<void> _handleUpdateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Logic for update would go here
      await Future.delayed(const Duration(seconds: 1)); // Mock
      setState(() => _isLoading = false);
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text("Success"),
          description: const Text("Profile updated correctly"),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, UserProvider userProvider) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Delete Account',
      text: 'Are you sure you want to permanently delete your account?',
      confirmBtnText: 'Yes, Delete',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        final result = await userProvider.deleteAccount();
        if (!context.mounted) return;
        if (result['status'] == 'success') {
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
    );
  }
}

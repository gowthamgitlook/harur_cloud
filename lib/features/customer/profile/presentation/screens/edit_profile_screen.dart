import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../auth/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              Stack(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarXL,
                    backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: AppSizes.iconXXL * 1.5,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(AppSizes.paddingSM),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: AppSizes.iconSM,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizes.spacingXS),

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo upload - Coming soon!')),
                  );
                },
                child: const Text('Change Profile Photo'),
              ),

              SizedBox(height: AppSizes.spacingXL),

              // Phone Number (Read-only)
              CustomTextField(
                controller: TextEditingController(text: user?.phone ?? ''),
                label: 'Phone Number',
                hint: 'Your phone number',
                prefixIcon: const Icon(Icons.phone),
                enabled: false,
              ),

              SizedBox(height: AppSizes.spacingMD),

              // Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Full Name *',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppSizes.spacingMD),

              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email (optional)',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),

              SizedBox(height: AppSizes.spacingXL),

              // Help Text
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: AppSizes.iconSM,
                    ),
                    SizedBox(width: AppSizes.spacingSM),
                    Expanded(
                      child: Text(
                        'Your phone number cannot be changed as it is linked to your account.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.spacingXL),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _isSaving ? null : _handleSave,
                isLoading: _isSaving,
                width: double.infinity,
              ),

              SizedBox(height: AppSizes.spacingMD),

              // Cancel Button
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please login again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Update user profile
    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    authProvider.updateUser(updatedUser);

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.success,
      ),
    );

    // Go back
    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Actually save the address using a provider
      
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Address Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppSizes.spacingLG),
                
                // Label
                CustomTextField(
                  controller: _labelController,
                  label: 'Label (e.g., Home, Office)',
                  hint: 'Home',
                  prefixIcon: const Icon(Icons.label),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a label';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.spacingMD),
                
                // Full Address
                CustomTextField(
                  controller: _addressController,
                  label: 'Full Address',
                  hint: 'Street, Area, City, State, Zip',
                  prefixIcon: const Icon(Icons.location_on),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the full address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.spacingMD),
                
                // Landmark
                CustomTextField(
                  controller: _landmarkController,
                  label: 'Landmark (Optional)',
                  hint: 'Near Bus Stand',
                  prefixIcon: const Icon(Icons.flag),
                ),
                
                SizedBox(height: AppSizes.spacingXL),
                
                // Save Button
                CustomButton(
                  text: 'Save Address',
                  onPressed: _saveAddress,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../config/app_config.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/address_model.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../auth/providers/auth_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  String _selectedLabel = 'Home';
  bool _isLoading = false;

  final List<String> _labelOptions = ['Home', 'Work', 'Other'];

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final newAddress = AddressModel(
        id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
        label: _selectedLabel,
        fullAddress: _addressController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
        latitude: AppConfig.harurLatitude,
        longitude: AppConfig.harurLongitude,
      );

      final updatedAddresses = List<AddressModel>.from(user.addresses)
        ..add(newAddress);
      authProvider.updateUser(user.copyWith(addresses: updatedAddresses));

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
                
                // Address Type
                Text(
                  'Address Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSizes.spacingSM),
                Row(
                  children: _labelOptions.map((label) {
                    final isSelected = _selectedLabel == label;
                    return Padding(
                      padding: EdgeInsets.only(right: AppSizes.spacingSM),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedLabel = label),
                        selectedColor: AppColors.primaryRed,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: AppSizes.spacingLG),

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

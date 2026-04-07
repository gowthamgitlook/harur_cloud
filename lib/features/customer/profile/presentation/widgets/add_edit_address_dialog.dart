import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/models/address_model.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../auth/providers/auth_provider.dart';

class AddEditAddressDialog extends StatefulWidget {
  final AddressModel? address; // Null for add, non-null for edit

  const AddEditAddressDialog({
    super.key,
    this.address,
  });

  @override
  State<AddEditAddressDialog> createState() => _AddEditAddressDialogState();
}

class _AddEditAddressDialogState extends State<AddEditAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  String _selectedLabel = 'Home';
  bool _isSaving = false;

  final List<String> _labelOptions = ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      // Pre-fill for edit mode
      _addressController.text = widget.address!.fullAddress;
      _landmarkController.text = widget.address!.landmark ?? '';
      _selectedLabel = widget.address!.label;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.address != null;

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLG),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditMode ? 'Edit Address' : 'Add Address',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.spacingLG),

                // Label Selection
                Text(
                  'Address Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                        onSelected: (selected) {
                          setState(() => _selectedLabel = label);
                        },
                        selectedColor: AppColors.primaryRed,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: AppSizes.spacingLG),

                // Address Field
                CustomTextField(
                  controller: _addressController,
                  label: 'Full Address *',
                  hint: 'Enter complete address',
                  prefixIcon: const Icon(Icons.location_on),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your address';
                    }
                    if (value.trim().length < 10) {
                      return 'Address must be at least 10 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: AppSizes.spacingMD),

                // Landmark Field
                CustomTextField(
                  controller: _landmarkController,
                  label: 'Landmark (Optional)',
                  hint: 'E.g., Near City Hospital',
                  prefixIcon: const Icon(Icons.place),
                ),

                SizedBox(height: AppSizes.spacingXL),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: AppSizes.spacingMD),
                    Expanded(
                      child: CustomButton(
                        text: isEditMode ? 'Update' : 'Add',
                        onPressed: _isSaving ? null : _handleSave,
                        isLoading: _isSaving,
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final newAddress = AddressModel(
      id: widget.address?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: _selectedLabel,
      fullAddress: _addressController.text.trim(),
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
      latitude: widget.address?.latitude ?? 12.0522, // Default Harur coordinates
      longitude: widget.address?.longitude ?? 78.4844,
    );

    List<AddressModel> updatedAddresses = List.from(user.addresses);

    if (widget.address != null) {
      // Edit mode - replace existing address
      final index = updatedAddresses.indexWhere((a) => a.id == widget.address!.id);
      if (index != -1) {
        updatedAddresses[index] = newAddress;
      }
    } else {
      // Add mode - add new address
      updatedAddresses.add(newAddress);
    }

    final updatedUser = user.copyWith(addresses: updatedAddresses);
    authProvider.updateUser(updatedUser);

    setState(() => _isSaving = false);

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.address != null
              ? 'Address updated successfully'
              : 'Address added successfully',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/utils/permissions_handler.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../providers/admin_menu_provider.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItemModel? menuItem;

  const AddEditMenuItemScreen({super.key, this.menuItem});

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  FoodCategory _selectedCategory = FoodCategory.biryani;
  bool _isPopular = false;
  bool _isAvailable = true;
  bool _isVeg = true;
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      _nameController.text = widget.menuItem!.name;
      _descriptionController.text = widget.menuItem!.description;
      _priceController.text = widget.menuItem!.price.toString();
      _selectedCategory = widget.menuItem!.category;
      _isPopular = widget.menuItem!.isPopular;
      _isAvailable = widget.menuItem!.isAvailable;
      _isVeg = widget.menuItem!.isVeg;
      _imageUrl = widget.menuItem!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await PermissionsHandler.showImagePicker(context);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AdminMenuProvider>();
      String imageUrl = _imageUrl ?? 'assets/images/placeholder.png';
      if (_selectedImage != null) {
        imageUrl = _selectedImage!.path;
      }

      final menuItem = MenuItemModel(
        id: widget.menuItem?.id ?? '',
        restaurantId: widget.menuItem?.restaurantId ?? 'res_1',
        restaurantName: widget.menuItem?.restaurantName ?? 'Harur Cloud Kitchen',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        category: _selectedCategory,
        isPopular: _isPopular,
        isAvailable: _isAvailable,
        isVeg: _isVeg,
        rating: widget.menuItem?.rating ?? 0.0,
        reviewCount: widget.menuItem?.reviewCount ?? 0,
        addons: widget.menuItem?.addons ?? [],
      );

      bool success;
      if (widget.menuItem == null) {
        success = await provider.addMenuItem(menuItem);
      } else {
        success = await provider.updateMenuItem(menuItem);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.menuItem == null ? 'Added' : 'Updated'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.menuItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Item' : 'Add Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                          child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                        )
                      : _imageUrl != null && _imageUrl!.startsWith('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                              child: Image.network(_imageUrl!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to add photo'),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingLG),

              CustomTextField(
                controller: _nameController,
                label: 'Item Name',
                hint: 'e.g. Chicken Biryani',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSizes.spacingMD),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe the dish...',
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSizes.spacingMD),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price (₹)',
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMD),
                  Expanded(
                    child: DropdownButtonFormField<FoodCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: FoodCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLG),

              SwitchListTile(
                title: const Text('Vegetarian'),
                value: _isVeg,
                activeColor: Colors.green,
                onChanged: (v) => setState(() => _isVeg = v),
              ),
              SwitchListTile(
                title: const Text('Mark as Popular'),
                value: _isPopular,
                activeColor: Colors.orange,
                onChanged: (v) => setState(() => _isPopular = v),
              ),
              SwitchListTile(
                title: const Text('Available'),
                value: _isAvailable,
                activeColor: AppColors.primaryRed,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),

              const SizedBox(height: AppSizes.spacingXL),
              CustomButton(
                text: isEditMode ? 'Update Item' : 'Add Item',
                onPressed: _isLoading ? null : _saveMenuItem,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

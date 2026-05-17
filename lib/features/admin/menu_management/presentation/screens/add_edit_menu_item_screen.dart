import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../core/utils/permissions_handler.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/widgets/animated_background.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? (widget.menuItem == null ? 'Item added successfully' : 'Item updated successfully')
                : 'Failed to save item'),
            backgroundColor: success ? GlassTheme.successGreen : GlassTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (success) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: GlassTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.menuItem != null;

    return AnimatedBackground(
      showParticles: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            isEditMode ? 'Edit Menu Item' : 'New Menu Item',
            style: GlassTheme.headlineLarge.copyWith(color: GlassTheme.darkBlue),
          ),
          iconTheme: const IconThemeData(color: GlassTheme.darkBlue),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Enhanced Image Picker
                _buildImagePicker().animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: 24),

                // 2. Form Container
                GlassMorphism(
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(32),
                  opacity: 0.1,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Item Name',
                        hint: 'e.g. Traditional Chicken Biryani',
                        validator: (v) => v!.isEmpty ? 'Item name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'A flavorful and aromatic biryani...',
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 20),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<FoodCategory>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: FoodCategory.values
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCategory = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // 3. Toggles Section
                _buildToggles().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 40),

                // 4. Save Button
                GlassButton(
                  text: isEditMode ? 'Save Changes' : 'Create Item',
                  onPressed: _isLoading ? () {} : _saveMenuItem,
                  isLoading: _isLoading,
                  icon: isEditMode ? Icons.save_rounded : Icons.add_rounded,
                ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: GlassMorphism(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(28),
        opacity: 0.1,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                )
              : _imageUrl != null && _imageUrl!.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(_imageUrl!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: GlassTheme.primaryBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo_rounded, size: 40, color: GlassTheme.primaryBlue),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Add Food Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GlassTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          'Tap to browse gallery or camera',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildToggles() {
    return GlassMorphism(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.05,
      child: Column(
        children: [
          _buildToggleItem(
            'Vegetarian',
            'Is this dish vegetarian?',
            _isVeg,
            GlassTheme.successGreen,
            (v) => setState(() => _isVeg = v),
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
          _buildToggleItem(
            'Popular Dish',
            'Show this in the popular section',
            _isPopular,
            Colors.orange,
            (v) => setState(() => _isPopular = v),
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
          _buildToggleItem(
            'In Stock',
            'Set item as available for orders',
            _isAvailable,
            GlassTheme.primaryBlue,
            (v) => setState(() => _isAvailable = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    Color activeColor,
    Function(bool) onChanged,
  ) {
    return SwitchListTile.adaptive(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeThumbColor: activeColor,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}

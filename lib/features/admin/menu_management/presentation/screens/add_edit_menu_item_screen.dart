import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/theme/glass_theme.dart';
import '../../../../../core/utils/permissions_handler.dart';
import '../../../../../shared/enums/food_category.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/models/addon_model.dart';
import '../../../../../shared/widgets/animated_background.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../providers/admin_menu_provider.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItemModel? menuItem; // null for add, non-null for edit

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
  XFile? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      // Edit mode - populate fields
      _nameController.text = widget.menuItem!.name;
      _descriptionController.text = widget.menuItem!.description;
      _priceController.text = widget.menuItem!.price.toString();
      _selectedCategory = widget.menuItem!.category;
      _isPopular = widget.menuItem!.isPopular;
      _isAvailable = widget.menuItem!.isAvailable;
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
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<AdminMenuProvider>();

      // In production, upload image to Firebase Storage here
      // For now, use asset path or selected image path
      String imageUrl = _imageUrl ?? 'assets/images/placeholder.png';
      if (_selectedImage != null) {
        // TODO: Upload to Firebase Storage
        imageUrl = _selectedImage!.path;
      }

      final menuItem = MenuItemModel(
        id: widget.menuItem?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        category: _selectedCategory,
        isPopular: _isPopular,
        isAvailable: _isAvailable,
        rating: widget.menuItem?.rating ?? 0.0,
        reviewCount: widget.menuItem?.reviewCount ?? 0,
        addons: widget.menuItem?.addons ?? [],
      );

      bool success;
      if (widget.menuItem == null) {
        // Add new item
        success = await provider.addMenuItem(menuItem);
      } else {
        // Update existing item
        success = await provider.updateMenuItem(menuItem);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.menuItem == null
                    ? 'Menu item added successfully'
                    : 'Menu item updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save menu item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.menuItem != null;

    return Scaffold(
      body: AnimatedBackground(
        colors: const [
          Color(0xFF0066FF),
          Color(0xFF00D4FF),
          Color(0xFF7B2CBF),
        ],
        showParticles: false,
        child: SafeArea(
          child: Column(
            children: [
              // Glass App Bar
              GlassCard(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditMode ? 'Edit Menu Item' : 'Add Menu Item',
                        style: GlassTheme.headlineLarge,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image Picker
                        GlassCard(
                          child: Column(
                            children: [
                              if (_selectedImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else if (_imageUrl != null)
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    size: 80,
                                    color: Colors.white54,
                                  ),
                                )
                              else
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 60,
                                          color: Colors.white54,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to add image',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              GlassButton(
                                text: _selectedImage != null || _imageUrl != null
                                    ? 'Change Image'
                                    : 'Pick Image',
                                onPressed: _pickImage,
                                icon: Icons.photo_library,
                                height: 48,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                        const SizedBox(height: 16),

                        // Name Field
                        GlassCard(
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Item Name *',
                              labelStyle: TextStyle(color: Colors.white70),
                              hintText: 'e.g., Chicken Biryani',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.restaurant, color: Colors.white70),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter item name';
                              }
                              if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                        const SizedBox(height: 16),

                        // Description Field
                        GlassCard(
                          child: TextFormField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              labelStyle: TextStyle(color: Colors.white70),
                              hintText: 'Describe the dish...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.description, color: Colors.white70),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter description';
                              }
                              if (value.trim().length < 10) {
                                return 'Description must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                        const SizedBox(height: 16),

                        // Price and Category Row
                        Row(
                          children: [
                            Expanded(
                              child: GlassCard(
                                child: TextFormField(
                                  controller: _priceController,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Price (₹) *',
                                    labelStyle: TextStyle(color: Colors.white70),
                                    hintText: '0.00',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.white70),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter price';
                                    }
                                    final price = double.tryParse(value.trim());
                                    if (price == null || price <= 0) {
                                      return 'Invalid price';
                                    }
                                    return null;
                                  },
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GlassCard(
                                child: DropdownButtonFormField<FoodCategory>(
                                  value: _selectedCategory,
                                  dropdownColor: GlassTheme.darkBlue,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Category *',
                                    labelStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.category, color: Colors.white70),
                                  ),
                                  items: FoodCategory.values.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category.displayName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    }
                                  },
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Switches
                        GlassCard(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Mark as Popular',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Show in popular items section',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                value: _isPopular,
                                activeColor: GlassTheme.secondaryBlue,
                                onChanged: (value) {
                                  setState(() {
                                    _isPopular = value;
                                  });
                                },
                              ),
                              const Divider(color: Colors.white24),
                              SwitchListTile(
                                title: const Text(
                                  'Available',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Customer can order this item',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                value: _isAvailable,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    _isAvailable = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                        const SizedBox(height: 24),

                        // Save Button
                        GlassButton(
                          text: isEditMode ? 'Update Item' : 'Add Item',
                          onPressed: _isLoading ? () {} : _saveMenuItem,
                          icon: isEditMode ? Icons.check : Icons.add,
                          isLoading: _isLoading,
                        ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../presentation/screens/available_deliveries_screen.dart';
import '../presentation/screens/active_deliveries_screen.dart';
import '../presentation/screens/delivery_history_screen.dart';

class DeliveryMainScreen extends StatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  State<DeliveryMainScreen> createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends State<DeliveryMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AvailableDeliveriesScreen(),
    const ActiveDeliveriesScreen(),
    const DeliveryHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primaryOrange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: AppStrings.available,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: AppStrings.active,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppStrings.history,
          ),
        ],
      ),
    );
  }
}


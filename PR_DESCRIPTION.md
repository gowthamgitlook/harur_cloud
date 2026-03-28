# Comprehensive Fixes and Enhancements for Harur Cloud Kitchen

## Summary
This PR addresses critical functional bugs, visual glitches, and implements missing features requested for the full application experience.

## Key Changes

### 1. Functional Fixes 🛠️
- **Cart Logic**: Fixed bug where items with different `specialInstructions` were merged incorrectly. Added quantity support.
- **Real-Time Dashboard**: `AdminOrderProvider` now auto-refreshes dashboard stats on order updates.
- **Payment Flow**: Connected `CheckoutScreen` to the new `AddAddressScreen` and refined the order placement logic with a simulated payment delay.

### 2. UI/UX Improvements 🎨
- **Layout Overflow**: Resolved `RenderFlex overflow` in `FoodItemCard` and `CustomerHomeScreen` by adjusting grid ratios and padding.
- **Live Tracking**: Integrated `LiveTrackingMap` into `OrderTrackingScreen`. The map now appears automatically when an order is "Out for Delivery".
- **Navigation**: Implemented navigation to `NotificationsScreen` and `AddAddressScreen`.

### 3. New Features & Simulation 🚀
- **Live Tracker Simulation**: Added a "mock movement" mode to `LocationTrackingService` that simulates a delivery partner moving around Harur. This activates automatically when `useMockServices` is true.
- **Assets Structure**: Created the `assets` directory structure to support local images and icons.
- **New Screens**: Added `AddAddressScreen` and `NotificationsScreen`.

## Testing
- **Cart**: Verified adding items with different notes creates separate entries.
- **Tracking**: Verified map appears for "Out for Delivery" orders and shows simulated movement.
- **Checkout**: Verified flow from Cart -> Checkout -> Add Address -> Place Order -> Success.

## Notes
- **Google Maps API Key**: Please update `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift` with your valid API key to see the map tiles.
- **Deprecations**: Addressed critical logic; some UI deprecations remain but do not affect functionality.

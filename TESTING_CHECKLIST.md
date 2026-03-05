# Harur Cloud Kitchen - Testing Checklist

## Test Accounts
- **Customer**: +919876543210 (OTP: 123456)
- **Admin**: +919876543211 (OTP: 123456)
- **Delivery Partner**: +919876543212 (OTP: 123456)

---

## 1. CUSTOMER FEATURES TESTING

### 1.1 Authentication
- [ ] Launch app - should show splash screen with animation
- [ ] After splash, should navigate to login screen
- [ ] Enter customer phone: +919876543210
- [ ] Tap "Send OTP" - should navigate to OTP screen
- [ ] Enter OTP: 123456
- [ ] Should successfully login and navigate to customer home screen

### 1.2 Home Screen & Menu
- [ ] Bottom navigation shows: Home, Orders, Cart, Profile
- [ ] Home screen displays menu categories: Biryani, Fried Rice, Parotta, Grill, Drinks
- [ ] Category filter chips work correctly
- [ ] Menu items display with images, names, prices, ratings
- [ ] "Popular" badge shows on popular items
- [ ] Search functionality works

### 1.3 Orders Screen (MAIN FIX)
- [ ] Tap "Orders" in bottom navigation
- [ ] Should see two tabs: Active and History
- [ ] **Active Tab**: Should show 2 orders
  - [ ] Order 1: Preparing status (Chicken Biryani + Egg Fried Rice, ₹597)
  - [ ] Order 2: Placed status (Chicken Kothu Parotta, ₹189)
  - [ ] Each order card shows: Order ID, items, price, status badge
  - [ ] Can tap order to view details
  - [ ] "Cancel Order" button visible on Placed order only
- [ ] **History Tab**: Should show 2 delivered orders
  - [ ] Order 3: Delivered (Mutton Biryani + Egg Parotta, ₹430.5)
  - [ ] Order 4: Delivered (Chicken Fried Rice, ₹325.5)
  - [ ] Each shows delivery date
  - [ ] "Reorder" button visible
- [ ] Pull to refresh works on both tabs

### 1.4 Cart & Checkout
- [ ] Go back to Home
- [ ] Tap on any menu item - should open details dialog
- [ ] Add item to cart with customizations (quantity, spice level, addons)
- [ ] Cart icon shows item count badge
- [ ] Tap Cart tab - should show cart items
- [ ] Can increase/decrease quantity
- [ ] Can remove items
- [ ] Shows subtotal, delivery fee, tax, total
- [ ] Tap "Proceed to Checkout"
- [ ] Select delivery address
- [ ] Select payment method
- [ ] Tap "Place Order" - should create new order
- [ ] Should navigate to order tracking screen
- [ ] New order should appear in Active Orders tab

### 1.5 Order Tracking
- [ ] Tap on any active order
- [ ] Should show order tracking screen
- [ ] Displays order timeline with status progression
- [ ] Shows order items, address, payment method
- [ ] Map shows delivery location (if out for delivery)
- [ ] Can contact delivery partner (if assigned)

### 1.6 Profile
- [ ] Tap Profile tab
- [ ] Should show user name, phone, email
- [ ] Can view/edit saved addresses
- [ ] Can view order statistics
- [ ] Settings option available
- [ ] Logout button works

---

## 2. ADMIN FEATURES TESTING

### 2.1 Admin Login
- [ ] Logout from customer account
- [ ] Login with admin phone: +919876543211, OTP: 123456
- [ ] Should navigate to admin dashboard

### 2.2 Admin Dashboard
- [ ] Bottom navigation shows: Dashboard, Orders, Menu, Profile
- [ ] **Stats Cards** display (2x2 grid):
  - [ ] Today Orders count
  - [ ] Today Revenue (₹)
  - [ ] Active Orders count (should be live - shows 2)
  - [ ] Month Revenue (₹)
- [ ] **Revenue Breakdown** card shows:
  - [ ] Today revenue
  - [ ] This Week revenue
  - [ ] This Month revenue
- [ ] **Popular Items** section:
  - [ ] Shows top 5 items with images and order counts
  - [ ] Horizontal scroll works
- [ ] **Active Orders** section:
  - [ ] Shows real-time list of active orders
  - [ ] Each shows order ID, customer, items, status

### 2.3 Admin Order Management
- [ ] Tap "Orders" tab
- [ ] Should see filter chips: All, Placed, Preparing, Out for Delivery, Delivered, Cancelled
- [ ] **All Orders** view:
  - [ ] Shows all 4 sample orders
  - [ ] Each card shows: Order ID, customer, items count, total, status badge
  - [ ] Tap on order - shows action buttons
- [ ] **Update Status Test**:
  - [ ] Tap "Update Status" on a Placed order
  - [ ] Dialog shows all status options with icons
  - [ ] Select "Preparing" - order updates instantly
  - [ ] Status badge changes color
  - [ ] Dashboard stats update in real-time
- [ ] **Assign Delivery Test**:
  - [ ] Update a Preparing order to "Out for Delivery"
  - [ ] Should auto-show "Assign Delivery Partner" dialog
  - [ ] Shows list of delivery partners (should show 1: Delivery Partner)
  - [ ] Select delivery partner
  - [ ] Order gets assigned (deliveryPartnerId set)
  - [ ] Order appears in delivery partner's Available tab
- [ ] **Filter Test**:
  - [ ] Tap "Preparing" chip - shows only preparing orders
  - [ ] Tap "Delivered" chip - shows only delivered orders
  - [ ] Tap "All" - shows all orders again

### 2.4 Admin Menu Management
- [ ] Tap "Menu" tab
- [ ] Should show all menu items with category filter tabs
- [ ] **View Menu**:
  - [ ] Category tabs work (All, Biryani, Fried Rice, Parotta, Grill, Drinks)
  - [ ] Each item shows: image, name, price, category, rating
  - [ ] Availability toggle visible
- [ ] **Toggle Availability**:
  - [ ] Turn off availability for "Chicken Biryani"
  - [ ] Switch should turn red/gray
  - [ ] Item should be marked unavailable in customer menu
- [ ] **Edit Item**:
  - [ ] Tap "Edit" icon on any item
  - [ ] Opens edit form with pre-filled data
  - [ ] Modify price or name
  - [ ] Tap "Save" - updates successfully
  - [ ] Changes reflect immediately
- [ ] **Add New Item**:
  - [ ] Tap FAB (+) button
  - [ ] Opens blank form
  - [ ] Fill: Name, Description, Price, Category, Image URL
  - [ ] Toggle "Is Popular" and "Is Available"
  - [ ] Tap "Save" - new item appears in list
- [ ] **Delete Item**:
  - [ ] Tap "Delete" icon on test item
  - [ ] Confirmation dialog appears
  - [ ] Confirm - item removed from list

### 2.5 Admin Profile
- [ ] Tap Profile tab
- [ ] Shows admin name, phone
- [ ] Logout button works

---

## 3. DELIVERY PARTNER FEATURES TESTING

### 3.1 Delivery Login
- [ ] Logout from admin account
- [ ] Login with delivery phone: +919876543212, OTP: 123456
- [ ] Should navigate to delivery main screen

### 3.2 Available Deliveries
- [ ] Bottom navigation shows: Available, Active, History
- [ ] **Available Tab**:
  - [ ] Should show orders assigned by admin
  - [ ] If admin assigned order in step 2.3, it appears here
  - [ ] Shows: Order ID, customer address, items, total
  - [ ] Info banner: "Orders assigned to you by admin"
  - [ ] If no assigned orders - shows empty state

### 3.3 Active Deliveries
- [ ] Tap "Active" tab
- [ ] **If order is Out for Delivery**:
  - [ ] Shows order details
  - [ ] Customer contact card with phone and address
  - [ ] "Call Customer" button works
  - [ ] "Mark as Complete" button visible
- [ ] **Mark Complete Test**:
  - [ ] Tap "Mark as Complete"
  - [ ] Confirmation dialog appears
  - [ ] Confirm - order status changes to Delivered
  - [ ] Order moves to History tab
  - [ ] Admin dashboard updates (active orders count decreases)
  - [ ] Customer sees order as Delivered
- [ ] If no active orders - shows empty state

### 3.4 Delivery History
- [ ] Tap "History" tab
- [ ] **Stats Card** at top shows:
  - [ ] Total Deliveries completed
  - [ ] Total Earnings (₹)
  - [ ] Delivery partner name and phone
- [ ] **History List**:
  - [ ] Shows all completed deliveries
  - [ ] Grouped by date (Today, Yesterday, etc.)
  - [ ] Each shows: Order ID, date/time, items count, earnings
  - [ ] Green checkmark icon
- [ ] **Logout**:
  - [ ] Scroll to bottom
  - [ ] Logout button works

---

## 4. CROSS-ROLE INTEGRATION TESTING

### 4.1 Complete Order Flow
1. [ ] **Customer**: Login, add items to cart, place new order
2. [ ] **Admin**: Login, see new order appear in dashboard Active Orders
3. [ ] **Admin**: Update order status: Placed → Preparing → Out for Delivery
4. [ ] **Admin**: Assign delivery partner when marking Out for Delivery
5. [ ] **Delivery**: Login, see order in Available/Active tab
6. [ ] **Delivery**: Mark order as Complete
7. [ ] **Customer**: Login, see order in History tab as Delivered
8. [ ] **Admin**: Dashboard stats updated (active orders decreased, revenue increased)

### 4.2 Real-Time Updates Test
1. [ ] Open app on customer account
2. [ ] Keep Orders screen open
3. [ ] From another device/emulator, login as admin
4. [ ] Update order status
5. [ ] **Expected**: Customer should see status update in real-time (via Stream)
6. [ ] Test with: Status changes, delivery assignments

### 4.3 Cancel Order Flow
1. [ ] **Customer**: Place new order
2. [ ] **Customer**: Immediately cancel it from Active Orders
3. [ ] Order status changes to Cancelled
4. [ ] Order moves to History tab
5. [ ] **Admin**: Should see order as Cancelled in dashboard
6. [ ] Cannot cancel if status is Preparing or later

---

## 5. EDGE CASES & ERROR HANDLING

### 5.1 Empty States
- [ ] New user with no orders - shows proper empty state
- [ ] No items in cart - shows empty cart message
- [ ] Delivery partner with no assignments - shows info message

### 5.2 Network Simulation (Mock Delays)
- [ ] Loading indicators show during data fetch
- [ ] Proper error messages if fetch fails
- [ ] Retry buttons work

### 5.3 Invalid Actions
- [ ] Cannot cancel order if already Preparing
- [ ] Cannot assign delivery if no delivery partners available
- [ ] Form validations work (menu item creation)

---

## 6. UI/UX TESTING

### 6.1 Navigation
- [ ] Bottom navigation works smoothly
- [ ] Back button navigation correct
- [ ] Deep links work (order details)

### 6.2 Responsiveness
- [ ] Works on different screen sizes
- [ ] Landscape mode works
- [ ] Scrolling is smooth

### 6.3 Visual
- [ ] Color scheme consistent (Orange primary)
- [ ] Status badges have correct colors
- [ ] Icons appropriate for each section
- [ ] Images load correctly
- [ ] Gradients render properly

### 6.4 Animations
- [ ] Splash screen animation smooth
- [ ] Card animations work
- [ ] Loading indicators animate
- [ ] Page transitions smooth

---

## 7. KNOWN ISSUES

### Non-Critical
1. ⚠️ **RenderFlex overflow** in food_item_card.dart (13px) - Visual only, doesn't affect functionality
2. ℹ️ **Deprecation warnings** - withOpacity, activeColor - Will be fixed in future Flutter updates

---

## TEST RESULTS

### Date: _________________
### Tester: _________________

**Customer Features**: ☐ Pass ☐ Fail
**Admin Features**: ☐ Pass ☐ Fail
**Delivery Features**: ☐ Pass ☐ Fail
**Integration**: ☐ Pass ☐ Fail
**Overall**: ☐ Pass ☐ Fail

### Notes:
```
_____________________________________________________________________
_____________________________________________________________________
_____________________________________________________________________
```

### Bugs Found:
1. _____________________________________________________________________
2. _____________________________________________________________________
3. _____________________________________________________________________

---

## AUTOMATED TESTING RECOMMENDATIONS

For production, implement:
1. **Unit Tests**: Provider logic, service methods, model validation
2. **Widget Tests**: Individual screen components
3. **Integration Tests**: Complete user flows
4. **Golden Tests**: UI screenshot regression testing

---

Generated with Claude Code

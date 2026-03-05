# Quick Testing Guide - Priority Tests

## 🚀 Setup
- **App Status**: ✅ Running on emulator
- **Sample Data**: ✅ 4 orders pre-loaded for customer user

---

## ⚡ QUICK 5-MINUTE TEST

### Test 1: View Orders (MAIN FIX) ⭐
```
1. Login as Customer: +919876543210, OTP: 123456
2. Tap "Orders" tab (bottom navigation)
3. Check Active tab → Should see 2 orders
4. Check History tab → Should see 2 delivered orders
✅ FIXED: "not able to view my orders" issue
```

### Test 2: Admin Dashboard ⭐
```
1. Logout → Login as Admin: +919876543211, OTP: 123456
2. Should see Dashboard with stats cards
3. Check "Active Orders" count = 2
4. Check Today Revenue, Popular Items
✅ Verify: Dashboard displays correctly
```

### Test 3: Update Order Status ⭐
```
1. Still as Admin → Tap "Orders" tab
2. Find a "Placed" order → Tap it
3. Tap "Update Status" → Select "Preparing"
4. Status should update instantly
5. Dashboard Active Orders updates automatically
✅ Verify: Real-time updates work
```

### Test 4: Assign Delivery ⭐
```
1. Still in Admin Orders
2. Find a "Preparing" order → Update to "Out for Delivery"
3. Should auto-show "Assign Delivery Partner" dialog
4. Select "Delivery Partner" → Assign
5. Order now has delivery partner assigned
✅ Verify: Delivery assignment flow works
```

### Test 5: Delivery Partner View ⭐
```
1. Logout → Login as Delivery: +919876543212, OTP: 123456
2. Tap "Available" tab → Should see assigned order from Test 4
3. Tap "Active" tab → Same order shown with customer details
4. Tap "Mark as Complete" → Confirm
5. Order moves to History tab
6. Check stats card shows earnings
✅ Verify: Delivery workflow complete
```

---

## 🎯 CRITICAL FEATURES TO TEST

### 1. Customer Orders ⭐⭐⭐
**What to test:**
- View Active orders (2 sample orders visible)
- View History orders (2 delivered orders visible)
- Order details screen
- Pull to refresh

**Expected behavior:**
- Orders display immediately on first load
- Status badges show correct colors
- Can tap to view order tracking

**Test Result:** ☐ Pass ☐ Fail

---

### 2. Admin Dashboard ⭐⭐⭐
**What to test:**
- Stats cards display correct counts
- Revenue breakdown (today/week/month)
- Popular items section
- Active orders real-time list

**Expected behavior:**
- All stats calculate correctly
- Popular items show based on delivered orders
- Real-time updates when orders change

**Test Result:** ☐ Pass ☐ Fail

---

### 3. Admin Order Management ⭐⭐⭐
**What to test:**
- View all orders
- Filter by status
- Update order status
- Assign delivery partner

**Expected behavior:**
- Filters work correctly
- Status updates reflect in real-time across all screens
- Auto-shows assign dialog when status = "Out for Delivery"

**Test Result:** ☐ Pass ☐ Fail

---

### 4. Admin Menu Management ⭐⭐
**What to test:**
- View menu items with categories
- Toggle item availability
- Edit existing item
- Add new item
- Delete item

**Expected behavior:**
- Category filters work
- Availability toggle updates in real-time
- CRUD operations complete successfully
- Changes visible to customers immediately

**Test Result:** ☐ Pass ☐ Fail

---

### 5. Delivery Partner Workflow ⭐⭐⭐
**What to test:**
- View available deliveries (assigned by admin)
- View active deliveries
- Mark delivery as complete
- View history and stats

**Expected behavior:**
- Orders appear when admin assigns them
- Can mark complete successfully
- Stats update correctly
- History shows all completed deliveries

**Test Result:** ☐ Pass ☐ Fail

---

### 6. Cross-Role Real-Time Updates ⭐⭐⭐
**What to test:**
- Admin updates order → Customer sees update
- Admin assigns delivery → Delivery partner sees order
- Delivery completes → Admin dashboard updates

**Expected behavior:**
- All updates happen in real-time via Stream
- No need to refresh manually
- Consistent data across all roles

**Test Result:** ☐ Pass ☐ Fail

---

## 🐛 KNOWN ISSUES

### Visual (Non-Critical)
1. **Food item card overflow**: 13px overflow in menu grid - doesn't affect functionality
   - Location: `lib/shared/widgets/food_item_card.dart:25`
   - Impact: Minor visual yellow stripes, content still visible

### Code Quality (Non-Critical)
1. **Deprecation warnings**: 83 warnings for withOpacity, activeColor
   - Will be addressed in future Flutter SDK updates
   - No impact on functionality

---

## 📊 TEST SUMMARY TEMPLATE

```
Date: ______________
Time Spent: ______________

✅ Customer Features:     [  ] Working [  ] Issues Found
✅ Admin Features:        [  ] Working [  ] Issues Found
✅ Delivery Features:     [  ] Working [  ] Issues Found
✅ Real-Time Updates:     [  ] Working [  ] Issues Found

Overall Status: [  ] PASS [  ] FAIL

Issues Found:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

Next Steps:
_______________________________________________
_______________________________________________
```

---

## 🎬 GETTING STARTED

**Current Status:**
- ✅ App is running on emulator
- ✅ Sample orders loaded
- ✅ All 3 user accounts ready

**To Start Testing:**
1. Look at the emulator screen
2. You should see the splash screen or login screen
3. Follow "Quick 5-Minute Test" above
4. Then proceed to detailed checklist in `TESTING_CHECKLIST.md`

**Need Help?**
- See full testing checklist: `TESTING_CHECKLIST.md` (331 tests)
- Test accounts in both files
- All features documented

---

## 📝 IMPORTANT NOTES

1. **Sample Orders**: Pre-loaded for customer user (ID: '1')
   - 2 Active: 1 Preparing, 1 Placed
   - 2 History: Both Delivered

2. **Real-Time**: All features use StreamController for live updates
   - No manual refresh needed
   - Changes propagate automatically

3. **Mock Data**: Currently using mock services
   - Production will need real API integration
   - Authentication is simplified (OTP always 123456)

4. **Auto Status Progression**: Disabled for testing
   - Orders won't automatically advance status
   - Admin must manually update for testing

---

Generated with Claude Code ✨

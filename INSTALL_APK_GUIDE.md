# 📱 Install Harur Cloud Kitchen on Your Phone

## ✅ APK Ready!
Your APK is built and ready at:
```
/Users/gowtham/Desktop/harur cloud/build/app/outputs/flutter-apk/app-release.apk
Size: 55.4 MB
```

---

## Method 1: Install via Bluetooth (Recommended for Local Transfer)

### Step 1: Share APK via Bluetooth from Mac
1. On your Mac, go to **System Settings > Bluetooth**
2. Make sure Bluetooth is ON
3. Make your Mac discoverable

### Step 2: Pair Your Phone
1. On your Android phone, go to **Settings > Bluetooth**
2. Turn ON Bluetooth
3. Find your Mac in the list and pair

### Step 3: Send APK File
1. On Mac, open **Finder**
2. Navigate to: `/Users/gowtham/Desktop/harur cloud/build/app/outputs/flutter-apk/`
3. Right-click on `app-release.apk`
4. Select **Share > Bluetooth**
5. Choose your paired phone
6. Click **Send**

### Step 4: Accept on Phone
1. You'll see a notification on your phone
2. Tap **Accept** to receive the file
3. The APK will be saved in **Downloads** folder

### Step 5: Install APK
1. Open **Files** or **Downloads** app on your phone
2. Find `app-release.apk`
3. Tap on it to install
4. You may see a warning: **"Install unknown apps"**
   - Tap **Settings**
   - Enable **"Allow from this source"**
   - Go back and tap **Install**
5. Tap **Open** to launch the app!

---

## Method 2: Install via USB Cable (Faster)

### Step 1: Connect Phone to Mac
1. Connect your Android phone to Mac using USB cable
2. On phone, tap notification and select **"File Transfer (MTP)"**

### Step 2: Transfer APK
1. On Mac, open **Android File Transfer** (download if needed from android.com/filetransfer)
2. Or use **Finder** sidebar (newer macOS)
3. Navigate to phone's **Download** folder
4. Copy `app-release.apk` from Mac to phone

### Step 3: Install
1. On phone, open **Files** or **Downloads** app
2. Tap on `app-release.apk`
3. Follow installation steps above

---

## Method 3: Install via ADB (For Developers)

```bash
# Connect phone via USB with USB Debugging enabled
cd "/Users/gowtham/Desktop/harur cloud"
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Enable Unknown Sources (If Needed)

If you can't install:
1. Go to **Settings > Security** (or **Apps & notifications**)
2. Find **"Install unknown apps"** or **"Unknown sources"**
3. Find your **Files** or **Downloads** app
4. Enable **"Allow from this source"**

---

## 🎨 What's New in This Version

### ✅ Light Theme
- White/light background
- Black text for better readability
- Clean, professional design
- Blue accents for buttons

### ✅ Admin Menu Management
- Add new menu items with image picker
- Edit existing items
- Delete with confirmation
- Toggle availability
- Category filtering

### ✅ Live Google Maps Tracking
- Real-time delivery partner location
- Distance calculation
- Route visualization
- Works for Customer, Admin, and Delivery roles

### ✅ Permissions Ready
- Camera (QR scanning, photos)
- Location (delivery tracking)
- Storage (image uploads)
- Phone calls
- Notifications

---

## 🗺️ Setup Google Maps (Important!)

### To Enable Live Tracking:

1. **Get Google Maps API Key:**
   - Go to: https://console.cloud.google.com/
   - Create a new project or select existing
   - Enable **"Maps SDK for Android"**
   - Go to **Credentials** → **Create Credentials** → **API Key**
   - Copy your API key

2. **Update AndroidManifest.xml:**
   - Open: `android/app/src/main/AndroidManifest.xml`
   - Find: `YOUR_GOOGLE_MAPS_API_KEY_HERE`
   - Replace with your actual API key
   - Rebuild APK: `flutter build apk --release`

3. **Restrict API Key (Security):**
   - In Google Cloud Console
   - Edit your API key
   - Under **Application restrictions**: Select **"Android apps"**
   - Add package name: `com.example.harur_cloud_kitchen`
   - Add SHA-1 certificate fingerprint (get from `keytool`)

---

## 📱 Test Accounts

Login with these numbers (OTP: **123456**):

| Role | Phone Number | Features |
|------|-------------|----------|
| **Customer** | +919876543210 | Browse menu, place orders, track delivery |
| **Admin** | +919876543211 | Manage menu, monitor orders, assign delivery |
| **Delivery** | +919876543212 | Accept deliveries, track route, mark complete |

---

## 🧪 Testing Checklist

### Customer Features:
- [ ] Login with OTP
- [ ] Browse menu (light theme!)
- [ ] Add items to cart
- [ ] Place order
- [ ] Track delivery with live map

### Admin Features:
- [ ] Login with OTP
- [ ] View dashboard
- [ ] **Add new menu item** (with image picker)
- [ ] **Edit menu item**
- [ ] **Delete menu item**
- [ ] Toggle availability
- [ ] View orders
- [ ] Assign delivery partner

### Delivery Features:
- [ ] Login with OTP
- [ ] View assigned deliveries
- [ ] Start tracking (GPS auto-starts)
- [ ] Navigate to customer
- [ ] Mark delivery complete

### Live Tracking:
- [ ] Customer sees delivery partner moving in real-time
- [ ] Distance updates as partner moves
- [ ] Admin can view all active deliveries
- [ ] Route line drawn between partner and customer

---

## 🐛 Troubleshooting

### "App not installed"
- **Cause**: Old version conflict or corrupted APK
- **Fix**: Uninstall old version first, then install new one

### "Parse error"
- **Cause**: Incompatible APK or corrupted file
- **Fix**: Re-download APK and try again

### Bluetooth transfer fails
- **Cause**: File too large (55MB) or Bluetooth timeout
- **Fix**: Use USB cable method instead

### Maps not showing
- **Cause**: Missing Google Maps API key
- **Fix**: Follow "Setup Google Maps" section above

### Location not updating
- **Cause**: Location permission not granted
- **Fix**:
  1. Go to **Settings > Apps > Harur Cloud Kitchen > Permissions**
  2. Enable **Location** (Allow all the time)

### Camera not working
- **Cause**: Camera permission not granted
- **Fix**: Enable Camera permission in app settings

---

## 📊 APK Information

| Detail | Value |
|--------|-------|
| **File Name** | app-release.apk |
| **Size** | 55.4 MB |
| **Version** | 1.0.0+1 |
| **Min Android** | Android 5.0 (API 21) |
| **Target Android** | Android 13 (API 33) |
| **Build Type** | Release (optimized) |

---

## 🚀 Next Steps After Installation

1. **First Time Setup:**
   - Grant all permissions when prompted
   - Enable location access (for delivery tracking)
   - Enable notifications (for order updates)

2. **For Testing:**
   - Test all three user roles
   - Try add/edit/delete menu items as admin
   - Place an order as customer
   - Accept and deliver as delivery partner

3. **For Google Maps:**
   - Get API key from Google Cloud Console
   - Update AndroidManifest.xml
   - Rebuild and reinstall APK

4. **Share Feedback:**
   - Test the light theme colors
   - Check if text is readable
   - Verify all features work properly

---

## 📞 Support

If you face any issues:
1. Check this guide's troubleshooting section
2. Verify all permissions are granted
3. Make sure location services are enabled
4. Check internet connection for maps

---

**Happy Testing! 🎉**

The app now has:
✅ Light theme with black text
✅ Admin menu management (add/edit/delete)
✅ Live Google Maps tracking
✅ QR code scanning
✅ All permissions configured

---

*Generated with Claude Code - March 5, 2026*

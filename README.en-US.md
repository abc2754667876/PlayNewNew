

# PlayNewNew Project User Guide (Mac + iPhone + Apple Watch)

This guide helps you run the `PlayNewNew` project on **real devices** (iPhone + Apple Watch).  
It is written step-by-step from scratch, so even without a technical background, you can complete it by following the instructions.

---

## I. Device Requirements

Please prepare the following devices:

- **Mac computer** (Apple Silicon strongly recommended, i.e., M-series chips like M1/M2/M3/M4)
- **iPhone 11 or later**
- **An Apple Watch already paired with that iPhone**

Notes:

- The Apple Watch must be properly paired with the iPhone before it can be used for debugging and app installation.
- For the first debug connection, it is recommended to keep device battery above 50% to avoid disconnection.

---

## II. System Requirements

- Apple Watch OS must be **watchOS 8.0 or later**

Recommendation:

- For stable Xcode debugging, update both the iPhone and Watch to the latest official OS versions.

---

## III. Software Requirements

### 1) Install Xcode on Mac

1. Open **App Store** on your Mac.
2. Search for `Xcode`.
3. Click "Get" or "Install" and wait for completion (it is large, so ensure enough disk space and download time).

### 2) Verify Xcode includes watchOS SDK

Usually installed together with Xcode. To check:

1. Open Xcode.
2. Menu bar: **Xcode -> Settings... -> Platforms**.
3. Check if `watchOS` platform components are listed; if not, click to install.

### 3) Enable "Developer Mode" on iPhone and Apple Watch

> Note: Developer mode is usually required for real-device debugging.  
> If you don't see this option on your device yet, please update to a newer system version and try again.

#### How to enable Developer Mode on iPhone

1. Go to **Settings**.
2. Go to **Privacy & Security**.
3. Scroll down to find **Developer Mode** and toggle it on.
4. Restart the iPhone as prompted.
5. After restart, confirm and enable Developer Mode again.

#### How to enable Developer Mode on Apple Watch

Try this path on the watch:

1. Open **Settings** on Apple Watch.
2. Go to **Privacy & Security**.
3. Find and enable **Developer Mode**.
4. Restart and confirm as prompted.

If the switch is not on the watch, first verify:

- iPhone and Watch are updated to OS versions supporting Developer Mode;
- Developer Mode is enabled on the iPhone;
- Retry while the Watch stays connected to the iPhone.

---

## IV. Additional Requirement: Apple Developer Account

You need to register an Apple Developer account and sign in with it in Xcode.

### 1) Register an Apple Developer Account (Apple Developer)

1. Prepare an Apple ID (register one if you don't have it).
2. Visit the [Apple Developer](https://developer.apple.com/) website.
3. Click **Account** in the top right and sign in with your Apple ID.
4. Follow the prompts to accept the developer agreement and complete your profile.
5. To publish to the App Store, join the paid Apple Developer Program as prompted.  
   For local real-device debugging only, a free personal developer signature is usually sufficient for basic testing.

### 2) Sign in to the Developer Account in Xcode

Follow this menu path:

- **Xcode -> Settings -> Apple Accounts -> Add Apple Account...**

After signing in, Xcode can use this account for code signing.

---

## V. Clone the Project (Download Project Code)

You can choose either method:

### Method 1: Download ZIP (Recommended for those unfamiliar with the command line)

1. Open the repository URL:  
   [https://github.com/abc2754667876/PlayNewNew](https://github.com/abc2754667876/PlayNewNew)
2. Click **Code** in the top right area.
3. Select **Download ZIP**.
4. Extract the downloaded file to get the `PlayNewNew` folder.

### Method 2: Clone via Terminal (Recommended for those with technical background)

1. Open the **Terminal** app on Mac.
2. Enter the following command and press Enter:

```bash
git clone https://github.com/abc2754667876/PlayNewNew.git
```

3. Once executed, a `PlayNewNew` folder will be created in the current directory.

---

## VI. Open the Project

1. Open the `PlayNewNew` project folder.
2. Double-click `PlayNewNew.xcodeproj`.
3. Wait for Xcode to finish loading (first-time opening may take a few minutes to index the project).

---

## VII. Configure Project Signing (Crucial)

1. In the left navigation pane of Xcode, click the top blue project item **PlayNewNew**.
2. In the center area, select the corresponding Targets (usually the main App and Watch App related targets; check all of them).
3. Open the **Signing & Capabilities** tab.
4. In the **Signing** section, select the developer account team you logged into in Step IV from the **Team** dropdown.

Recommendations:

- **Bundle Identifier** should not conflict with existing projects (change it to your own unique identifier if necessary).
- Ensure the signing team is consistent for both the main App and Watch App.

---

## VIII. Run the Project on Apple Watch

1. Ensure **Mac, iPhone, and Apple Watch are on the same network**, and keep devices unlocked.
2. Connect the iPhone to the Mac via a data cable (wired connection is recommended for the first debug session for better stability).
3. In the top device selection bar in Xcode, select your **Apple Watch target device** (or the paired iPhone + Watch run destination).
4. Click the **▶ (Run)** button in the top left to start building and installing.
5. On first run, if the device prompts "Trust this Developer" or debug authorization, allow it as prompted.

---

## Troubleshooting (Bookmark Recommended)

### 1) Can't see Apple Watch run destination

- Confirm Watch is successfully paired with iPhone.
- Confirm iPhone is trusted by Mac and recognized in Xcode.
- Retry by reconnecting the cable, restarting Xcode, or rebooting iPhone/Watch.

### 2) Signing/Provisioning errors

- Go back to `Signing & Capabilities` and confirm `Team` is correctly selected.
- Check if both main App and Watch App Targets have signing configured.
- Confirm Apple ID is signed in Xcode and status is normal.

### 3) First build is very slow

- This is normal (dependency resolution, indexing, and first compilation take time). Please be patient.
- Subsequent builds will be significantly faster.

---

## Tips for Different Readers

- **If you are a beginner**: Follow this README strictly in order. Do not skip steps.
- **If you are a developer**: Configure the account and signing first, then select the target device and debug on real hardware. This reduces troubleshooting time.

Wishing you a smooth run of `PlayNewNew` on your Apple Watch real device.

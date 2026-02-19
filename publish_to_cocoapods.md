# 📦 Publishing `DeunaSDK` Library to CocoaPods

## 1️⃣ Install CocoaPods
Ensure you have Homebrew installed, then install CocoaPods:

```bash
brew install cocoapods
```

Verify the installation:

```bash
pod --version
```

---

## 2️⃣ Sign In to CocoaPods
Register your CocoaPods account by running the following commands:

```bash
pod setup
pod repo update
pod trunk register dmorocho@deuna.com 'Deuna' --description='My Mac'
```

✅ **Verify your login status:**

```bash
pod trunk me
```

---

## 3️⃣ Publish the Library
Navigate to the root folder of the `deuna-sdk-ios` project:

```bash
cd path/to/deuna-sdk-ios
```

Then, publish the library:

```bash
pod trunk push DeunaSDK.podspec --allow-warnings
```

⚠️ **Important Notes:**
- Ensure the `.podspec` file is correctly configured.
- Update the version number if the current one is already published.
- Verify the `LICENSE` file is present and correctly referenced.

---

## 🚀 You're all set!
Your `DeunaSDK.podspec` library should now be published on CocoaPods! 🎉


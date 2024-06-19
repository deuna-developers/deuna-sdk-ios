# Basic Integration Example App

Basic Integration is a pre-built UI that shows how to use DEUNAs SDK library to complete a payment

### Features
- Supports all of DEUNAs supported payment methods [Listed here](https://docs.deuna.com/docs)
- Helps you stay PCI compliant


### To run the example app

1. Open the example project `deuna-sdk-ios/Examples/basic-integration` and open `basic-integration.xcodeproj` in Xcode.
2. Wait for xcode to download the project dependencies and index the project.
3. Navigate to the `basic_integrationApp.swift` file and locate the following code snippet. Replace `YOUR_PUBLIC_API_KEY` with your actual public API key and choose the appropriate environment (e.g., `.sandbox` or `.production`).

```swift
deunaSDK: DeunaSDK(
    environment: .sandbox, 
    publicApiKey: "YOUR_PUBLIC_API_KEY"
)
```
4. Choose any simulator and click Run

The example app will show you a button to complete the payment that will open the payment view
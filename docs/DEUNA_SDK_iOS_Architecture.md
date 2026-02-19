# DEUNA SDK iOS - Technical Architecture Documentation

## General Information

| Aspect | Detail |
|--------|--------|
| **SDK Name** | DeunaSDK |
| **Platform** | iOS 13.0+ |
| **Language** | Swift 5.8+ |
| **Dependency Manager** | Swift Package Manager |
| **Repository** | deuna-sdk-ios |

---

## 1. SDK Architecture

### 1.1 Architectural Pattern

The SDK uses a **WebView-based architecture with Delegate/Callback pattern**. It does not strictly follow MVVM or Clean Architecture, but rather a pragmatic approach oriented to:

- **Main class** (`DeunaSDK`) supporting both **singleton** and **instance-based** usage
- **Specialized ViewControllers** for each widget
- **JavaScript ↔ Swift communication** via `WKScriptMessageHandler`
- **Callback system** to notify events to the host app

### 1.2 DeunaSDK Instantiation

The `DeunaSDK` class supports **two usage patterns**:

**1. Singleton Pattern:**
```swift
// Initialize once (typically in AppDelegate or app startup)
DeunaSDK.initialize(environment: .production, publicApiKey: "your-api-key")

// Access anywhere via shared instance
DeunaSDK.shared.initPaymentWidget(...)
```

**2. Instance-based Pattern:**
```swift
// Create independent instances as needed
let deunaSDK = DeunaSDK(environment: .production, publicApiKey: "your-api-key")
deunaSDK.initPaymentWidget(...)
```

Both patterns are fully supported. Use singleton for simple apps with a single configuration, or instances when you need multiple SDK configurations or isolated widget contexts.

```
┌─────────────────────────────────────────────────────────────────┐
│                        App Host (Client)                         │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         DeunaSDK                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  - configuration: DeunaSDKConfiguration (store the env & public api key)               │    │
│  │  + deunaWebViewController: DeunaWebViewController? (the UIViewController that shows the the DEUNA widget in a webview as a modal or embedded)      │    │
│  │  + initCheckout()                                        │    │
│  │  + initPaymentWidget()                                   │    │
│  │  + initElements()                                        │    │
│  │  + initNextAction()                                      │    │
│  │  + initVoucher()                                         │    │
│  │  + close() / dispose()                                   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Widget Controllers                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │ Checkout     │ │ PaymentWidget│ │ Elements     │             │
│  │ ViewController│ │ ViewController│ │ ViewController│           │
│  └──────────────┘ └──────────────┘ └──────────────┘             │
│  ┌──────────────┐ ┌──────────────┐                              │
│  │ NextAction   │ │ Voucher      │                              │
│  │ ViewController│ │ ViewController│                             │
│  └──────────────┘ └──────────────┘                              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DeunaWebViewController                        │
│  (Base class - extends of BaseWebViewController)                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  - WKWebView (WebKit)                                    │    │
│  │  - JavaScript Bridge (xprops)                            │    │
│  │  - ExternalUrlHandler                                    │    │
│  │  - Loader/UI Components                                  │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Directory Structure

```
Sources/DeunaSDK/
├── DeunaSDK.swift                 # Main class (Singleton + Instance)
├── InitCheckout.swift             # Checkout extension to show the checkout widget as page sheet or as SwiftUI view
├── InitPaymentWidget.swift        # Payment widget extension to show the payment widget as page sheet or as SwiftUI view
├── InitElements.swift             # Vault/elements extension to show the vault/elements widget as page sheet or as SwiftUI view
├── initNextAction.swift           # Next action extension to show the next action widget as page sheet or as SwiftUI view
├── initVoucher.swift              # Voucher extension to show the voucher widget as page sheet or as SwiftUI view
├── GenerateFraudId.swift          # Fraud ID generation throw a web view that executes the DEUNA CDL script
│
├── Shared/                        # Shared components
│   ├── Callbacks.swift            # Callback protocols and types that are used by multiple widgets
│   ├── Environment.swift          # Environment configuration (develop, staging, sandbox, production)
│   ├── Errors.swift               # Error types for the Payment Widget, Checkout Widget, etc.
│   ├── constants.swift            # Global constants
│   ├── NetworkUtils.swift         # Network utilities
│   ├── Logger.swift               # Logging system
│   └── Enums/                     # Enumerations for widget integration (modal or embedded) & close actions (user or system)
│
├── Widgets/                       # Widget controllers
│   ├── Checkout/
│   │   ├── CheckoutWidgetController.swift
│   │   ├── CheckoutEvent.swift      # Events for the checkout widget, payment widget, next action widget and voucher widget.
│   │   └── CheckoutWidgetCallbacks.swift # Checkout Widget callbacks
│   ├── PaymentWidget/
│   │   ├── PaymentWidgetController.swift
│   │   ├── PaymentWidgetCallbacks.swift  # Payment Widget callbacks, equivalent to the Web SDK callbacks
│   │   └── PaymentWidgetEventHandler.swift
│   ├── Elements/
│   │   ├── ElementsWidgetController.swift
│   │   ├── ElementsEvent.swift      # Events for the elements widget (vault & click to pay).
│   │   └── ElementsCallbacks.swift  # Elements Widget callbacks, equivalent to the Web SDK callbacks
│   ├── NextAction/
│   └── Voucher/
│
├── WebView/                       # WebView infrastructure
│   ├── Base/
│   │   ├── BaseWebViewController.swift # Base WebView controller with the base functionality for WebViews
│   │   └── Controller.swift       # WKNavigationDelegate implementation to listen to navigation events, intercept redirect URLs and handle file downloads
│   ├── DeunaWebViewController.swift # Main WebView controller with the base functionality for DEUNA widgets
│   ├── NewTabWebView.swift        # New Webview used to open redirect URLs
│   ├── DeunaWebviewExtensions/
│   │   ├── JsInjection.swift        # SetUp the WebView configuration and to be able to inject JavaScript and emit local post messages
│   │   ├── RemoteJsFunctions.swift  # Reusable function to inject and execute JavaScript in the WebView
│   │   └── BuildLoaderAndLineBar.swift # Builds the loader and line bar for the WebView
│   └── FileDownloader/            # File downloader for WebView, used to download files from the web
│
├── ExternalUrlHandler/            # External URL handling
│   └── ExternalUrlHandler.swift   # Handles redirects and opens URLs in a new WebView or a SafariViewController
│
├── SwiftUI/                       # SwiftUI support
│   └── DeunaWidget.swift          # Show different subtypes of DeunaWidgetController as SwiftUI views
│
└── Extensions/                    # DeunaSDK extensions
    ├── WebViewPresentation.swift  # Extension that contains methods for presenting WebViews as SwiftUI views
    └── PaymentWidgetSubmitStrategy.swift  # Extension for payment widget submit strategy (For Paypal compatibility)
```

### 1.4 Swift Extensions Pattern

The SDK uses **Swift extensions** extensively to keep files small, organized, and maintainable. Extensions allow splitting class functionality across multiple files without inheritance.

#### 1.4.1 DeunaSDK Extensions

Located in the root and `Extensions/` directory, these extend the main `DeunaSDK` class:

| File | Extension of | Purpose |
|------|--------------|---------|
| `InitCheckout.swift` | `DeunaSDK` | - Constains the `initCheckout(...)` method that creates an instance of `CheckoutWidgetController`. - `checkoutWidget` method to display the checkout widget as a SwiftUI view |
| `InitPaymentWidget.swift` | `DeunaSDK` | - Constains the `initPaymentWidget()` method that creates an instance of `PaymentWidgetController`. - `paymentWidget` method to display the payment widget as a SwiftUI view |
| `InitElements.swift` | `DeunaSDK` | - Constains the `initElements()` method that creates an instance of `ElementsViewController`. - `elementsWidget` method to display the elements widget as a SwiftUI view |
| `initNextAction.swift` | `DeunaSDK` | - Constains the `initNextAction()` method that creates an instance of `NextActionViewController`. - `nextActionWidget` method to display the next action widget as a SwiftUI view |
| `initVoucher.swift` | `DeunaSDK` | - Contains the `initVoucher()` method that creates an instance of `VoucherController`. - `voucherWidget` method to display the voucher widget as a SwiftUI view. |
| `Extensions/WebViewPresentation.swift` | `DeunaSDK` | - Constains the `showWebView()` method to show an instance of `DeunaWebViewController` as a page sheet (modal). - `onWidgetClosed()` method to be called when the web view is dismissed & cleaned up |
| `Extensions/PaymentWidgetSubmitStrategy.swift` | `DeunaSDK` | `paymentWidgetSubmitStrategy()` used to call to the submit javascript function in the web view, only for the Payment Widget. It's used to determinate if the Paypal 2 steps flow must be launched or the submit javascript function must be called directly. |
| `GenerateFraudId.swift` | `DeunaSDK` | - Contains the `generateFraudId()` method that generates a fraud ID using an invisible web view that loads a specific URL that exposes a javascript function to get the fraud ID using the DEUNA CDL. |

#### 1.4.2 DeunaWebViewController Extensions

Located in `WebView/DeunaWebviewExtensions/`, these extend the base web view controller:

| File | Extension of | Purpose |
|------|--------------|---------|
| `JsInjection.swift` | `DeunaWebViewController` | `injectJs()` Injects `window.xprops` and registers message handlers to be able to listen the post messages emitted by the DEUNA Widget. |
| `JsMessagesHandler.swift` | `DeunaWebViewController` | Overrides `userContentController(_:didReceive:)` - Base handler for JS messages |
| `RemoteJsFunctions.swift` | `DeunaWebViewController` | Defines the functions `setCustomStyle()`, `refetchOrder()`, `isValid()`, `submit()`, `getWidgetState()`, `takeScreenshot()` that call to their respective javascript functions in the web view |
| `BuildLoaderAndLineBar.swift` | `DeunaWebViewController` | UI helpers: `setupLoader()`, `showLoader()`, `hideLoader()`, `addDismissLineBar()` - Methods to build and manage the loader and dismiss line bar |

#### 1.4.3 Widget-Specific Extensions

Each widget controller has its own event handler extension:

| File | Extension of | Purpose |
|------|--------------|---------|
| `Widgets/PaymentWidget/PaymentWidgetEventHandler.swift` | `PaymentWidgetViewController` | Contains the `handleEventData(...)` method that processes the post messages received from the WebView, parse the data and call the appropriate callback methods. |
| `Widgets/NexAction/NextActionEventHandler.swift`| `NextActionViewController` | Contains the `handleEventData(...)` method that processes the post messages received from the WebView, parse the data and call the appropriate callback methods. |
| `Widgets/Voucher/VoucherEventHandler.swift`| `VoucherViewController` | Contains the `downloadVoucher(...)` method that processes the download voucher event received from the WebView. |

#### 1.4.4 UIKit Extensions

| File | Extension of | Purpose |
|------|--------------|---------|
| `Extensions/WebViewPresentation.swift` | `UIApplication` | `getTopViewController()` - Finds the topmost view controller for modal presentation |

#### 1.4.5 Benefits of This Pattern

- **Smaller files**: Each file focuses on a single responsibility
- **Better organization**: Related functionality is grouped together
- **Easier maintenance**: Changes to one feature don't affect others
- **Parallel development**: Multiple developers can work on different extensions
- **Clear separation**: Widget initialization, JS injection, UI, and event handling are separated

---

## 2. Payment Flows with Redirection (APMs & 3DS)

### 2.1 What are APMs?

**APM (Alternative Payment Methods)** are alternative payment methods that require redirection to an external page (e.g., MercadoPago, PSE, banks, etc.).

### 2.2 What are 3DS?

**3DS (3D Secure)** is a security protocol that requires redirection to an external page (e.g., bank's authentication page) to verify the cardholder's identity.

### 2.3 Redirection Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DEUNA SDK                                       │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    Original WebView (Main)                            │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │  DEUNA Widget loaded                                            │  │   │
│  │  │  - Listening to events via window.xprops                        │  │   │
│  │  │  - Detects redirect attempt → intercepts navigation             │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                        │   │
│  │                              │ Redirect detected                      │   │
│  │                              ▼                                        │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │  ExternalUrlHandler                                             │  │   │
│  │  │  - Opens new WebView (PageSheet) OR SFSafariViewController      │  │   │
│  │  │  - Original WebView KEEPS listening to events                   │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                        │   │
│  └──────────────────────────────│────────────────────────────────────────┘   │
│                                 │                                            │
│                                 ▼                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │              Redirect WebView / SFSafariViewController                │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │  External URL (3DS, APM, Bank, etc.)                            │  │   │
│  │  │  - User completes authentication/payment                        │  │   │
│  │  │  - Redirects back to DEUNA                                      │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                 │                                            │
│                                 │ Redirect completes                         │
│                                 ▼                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    Original WebView receives event                    │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │  Event: purchaseError → Close redirect, call onError callback   │  │   │
│  │  │  Event: purchase      → Close redirect, call onSuccess callback │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                 │                                            │
│                                 ▼                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    Merchant App                                       │   │
│  │  ┌────────────────────────────────────────────────────────────────┐  │   │
│  │  │  onSuccess callback executed                                    │  │   │
│  │  │  Merchant processes result                                      │  │   │
│  │  │  Calls deunaSDK.close() to destroy all WebViews                 │  │   │
│  │  └────────────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Points:**
1. **Original WebView never stops listening** - It continues receiving events even during redirect
2. **Redirect opens in separate view** - New WebView (PageSheet) or SFSafariViewController
3. **Events control the flow** - `purchaseError` closes redirect and calls `onError`, `purchase` calls `onSuccess`
4. **Merchant must call `deunaSDK.close()`** - After processing the callback, merchant destroys all WebViews

### 2.4 Technical Implementation

The SDK handles APM redirections through:

1. **External URL detection** in `Controller.swift`:
```swift
// Detects if navigation should open in new tab
let isExternalUrl = navigationAction.targetFrame == nil

if isExternalUrl {
    decisionHandler(.cancel)
    delegate?.onOpenInNewTab(url)
}
```

2. **ExternalUrlHandler** manages the opening:
```swift
enum ExternalUrlHandlerBrowser {
    case safariView    // For specific domains (e.g., mercadopago.com)
    case webView       // Internal WebView for other APMs
}
```

3. **Domains requiring SafariViewController**:
```swift
let domainsRequiringSafariViewController = ["mercadopago.com"]
```

4. **APM Events**:
- `apmClickRedirect`: User clicks on APM redirection
- `apmSuccess` / `apmSuccessful`: Successful APM payment
- `apmSaveId`: APM voucher download

### 2.5 APM/3DS Closure

When the redirect completes and the original WebView receives an event:
```swift
// On error event - close redirect and notify error
externalUrlHandler.closeExternalUrlWebView()
callbacks.onError?(error)

// On success event - close redirect and notify success
externalUrlHandler.closeExternalUrlWebView()
callbacks.onSuccess?(data["order"] as! Json)

// Merchant must then call deunaSDK.close() to destroy all WebViews
```

---

## 3. Web SDK vs iOS SDK Comparison

### 3.1 Key Differences Overview

| Aspect | Web SDK | iOS SDK |
|--------|---------|---------|
| **Widget Loading** | iframe using **zoid** library | **WKWebView** |
| **Event Listening** | Callbacks passed to zoid (checkout-base, elements-link) | JavaScript injection with `window.xprops` + local postMessage |
| **Voucher Capture** | `window.print()` | JS injection with **html2canvas** library + base64 download |
| **URL Redirection (3DS/APMs)** | `window.open()` with window close detection | Override `window.open` → new WebView or SFSafariViewController |
| **Polling** | HTTP polling in web frontend | Delegated to WebView (no native polling) |

### 3.2 Widget Loading

**Web SDK:**
- Uses **zoid** library to load DEUNA widgets in an iframe
- Event callbacks are passed directly to zoid configuration
- Events are listened in `checkout-base` and `elements-link`

**iOS SDK:**
- Uses **WKWebView** to load DEUNA widgets
- Cannot use zoid directly, so JavaScript injection is required
- Injects `window.xprops` at document start to simulate zoid's callback mechanism

### 3.3 Event Communication

**Web SDK:**
```javascript
// zoid handles callbacks automatically
Checkout({
    onEventDispatch: (event) => { /* handle event */ }
});
```

**iOS SDK:**
```javascript
// JavaScript injection at document start
window.xprops = {
    onEventDispatch: function (event) {
        // Extra step: emit local postMessage for native communication
        window.webkit.messageHandlers.xprops.postMessage(JSON.stringify(event));
    },
    // ... other handlers
};
```

The iOS SDK adds an **extra step**: converting zoid-style callbacks into `WKScriptMessageHandler` postMessages for Swift/native code communication.

### 3.4 URL Redirection Handling (3DS/APMs)

**Web SDK:**
- Uses `window.open()` to open external URLs
- Can detect when the opened window is closed
- Maintains widget state in the original window

**iOS SDK:**
- **Problem**: If external URLs load in the same WebView, widget event listening is lost
- **Solution**: Override `window.open` and `window.close`
- External URLs open in:
  - **New WebView** (for most APMs)
  - **SFSafariViewController** (for specific domains like mercadopago.com)
- Original WebView maintains widget state and event listening

```swift
enum ExternalUrlHandlerBrowser {
    case safariView    // SFSafariViewController for specific domains
    case webView       // New WebView for other redirections
}
```

### 3.5 Voucher/Screenshot Capture

**Web SDK:**
- Uses native `window.print()` for voucher capture
- Browser handles print dialog and PDF generation

**iOS SDK:**
- **Problem**: `window.print()` does not work in iOS WebView
- **Solution**: Dynamic JavaScript injection
  1. Inject **html2canvas** library dynamically
  2. Capture WebView as canvas
  3. Convert to base64 image
  4. Send via local postMessage to native code
  5. Save image to device photo library

```javascript
// Dynamically inject html2canvas if not present
if (typeof html2canvas === "undefined") {
    var script = document.createElement("script");
    script.src = "https://html2canvas.hertzen.com/dist/html2canvas.min.js";
    script.onload = function () { takeScreenshot(); };
    document.head.appendChild(script);
}
```

### 3.6 Polling Behavior

| Aspect | Web | Mobile (iOS SDK) |
|--------|-----|------------------|
| **Polling** | Implemented in web frontend | **NO native polling in SDK** |
| **Communication** | HTTP polling | JavaScript Bridge (postMessage) |
| **State** | Managed by web app | Delegated to WebView |

The SDK **does NOT implement direct polling**. The web frontend inside the WebView handles all polling logic.

### 3.7 Payment Status Events

```swift
public enum CheckoutEvent: String {
    case paymentProcessing    // Payment in progress
    case purchase             // Successful payment
    case purchaseError        // Payment error
    case purchaseRejected     // Payment rejected
    // ...
}
```

---

## 4. External Dependencies

### 4.1 Package Dependencies

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/deuna-developers/deuna-ios-client", 
             .upToNextMajor(from: "1.4.11"))
]
```

| Dependency | Purpose |
|------------|---------|
| `deuna-ios-client` | API client for DEUNA backend communication |

### 4.2 System Frameworks

| Framework | Usage |
|-----------|-------|
| `WebKit` | WKWebView for rendering widgets |
| `UIKit` | UI components, ViewControllers |
| `SwiftUI` | SwiftUI integration support |
| `Foundation` | Networking, JSON, utilities |
| `SystemConfiguration` | Connectivity verification |
| `SafariServices` | SFSafariViewController for APMs |

### 4.3 External Resources (CDN)

```swift
// Fraud ID generation
"https://cdn.stg.deuna.io/mobile-sdks/get_fraud_id.html"

// Screenshot library (dynamically loaded)
"https://html2canvas.hertzen.com/dist/html2canvas.min.js"
```

---

## 5. Vaulting in Mobile

### 5.1 What is Vaulting?

**Vaulting** allows saving payment methods (cards) securely for future use.

### 5.2 Implementation in iOS

Vaulting is handled through the **Elements** widget:

```swift
public func initElements(
    userToken: String?,
    callbacks: ElementsCallbacks,
    closeEvents: Set<ElementsEvent> = [],
    userInfo: UserInfo? = nil,
    types: [Json] = [],           // Types of elements to display
    // ...
)
```

### 5.3 Elements Types

```swift
public enum ElementsWidget {
    public static let vault = "vault"
    public static let clickToPay = "click_to_pay"
}
```

### 5.4 Vaulting Events

```swift
public enum ElementsEvent: String {
    case vaultStarted              // Vault started
    case vaultProcessing           // Processing
    case vaultSaveClick            // Save click
    case vaultSaveSuccess          // Successfully saved
    case vaultSaveError            // Save error
    case vaultFailed               // General failure
    case vaultClosed               // Vault closed
    case cardSuccessfullyCreated   // Card created
    case cardCreationError         // Card creation error
    // ...
}
```

### 5.5 Vaulting Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ initElements │────▶│ Elements     │────▶│ vaultSave    │
│ (userToken)  │     │ WebView      │     │ Success      │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │ Callbacks:   │
                     │ - onSuccess  │
                     │ - onError    │
                     └──────────────┘
```

### 5.6 Vault Authentication
When the `initElements` method is called, the SDK can authenticate the user in two ways using the following parameters:
- **userToken**: Authenticated user token (skip OTP)
- **userInfo**: User information for registration

```swift
public class UserInfo {
    let firstName: String
    let lastName: String
    let email: String
}
```

---

## 6. Available Widgets

### 6.1 Widgets Summary

| Widget | Function | Initialization Method |
|--------|----------|----------------------|
| **Checkout** | Complete checkout flow | `initCheckout()` |
| **Payment Widget** | Payment Widget | `initPaymentWidget()` |
| **Elements** | Card vault, Click to Pay | `initElements()` |
| **Next Action** | Pending actions (3DS, etc.) | `initNextAction()` |
| **Voucher** | Display payment vouchers | `initVoucher()` |

### 6.2 Integration Modes

```swift
enum WidgetIntegration: String {
    case modal      // Modal presentation (default)
    case embedded   // Embedded in SwiftUI View
}
```

### 6.3 SwiftUI Support

```swift
@available(iOS 14.0, *)
public struct DeunaWidget: View {
    public let deunaSDK: DeunaSDK
    public let configuration: DeunaWidgetConfiguration
    // ...
}
```

---

## 7. Callback System

### 7.1 Base Structure

```swift
public class BaseCallbacks<EventData, Error> {
    public let onSuccess: OnSuccess?           // (Json) -> Void
    public let onError: OnError<Error>?        // (Error) -> Void
    public let onClosed: OnClosed?             // (CloseAction) -> Void
    public let onEventDispatch: OnEventDispatch<EventData>?  // (Event, Json) -> Void
}
```

### 7.2 Extended Callbacks

Callback classes extend `BaseCallbacks` without adding any new properties or methods.

- `CheckoutCallbacks: BaseCallbacks<CheckoutEvent, PaymentsError>`.
- `ElementsCallbacks: BaseCallbacks<ElementsEvent, ElementsError>`.

### 7.2 Specific Callbacks 
Extends of `BaseCallbacks` and adds additional callbacks used by the Payment Widget, Next Action and Voucher widgets:
**PaymentWidgetCallbacks**:
```swift
public let onCardBinDetected: OnPayload?
public let onInstallmentSelected: OnPayload?
public let onPaymentProcessing: VoidCallback?
```

### 7.3 Close Types
Enum passed to the `onClosed` callback to indicate how the widget was closed.

```swift
public enum CloseAction {
    case userAction    // User closed manually
    case systemAction  // When the widget is closed by deunaSDK.close() function
}
```

---

## 8. Environments

```swift
@objc public enum Environment: Int {
    case development  // api.dev.deuna.io
    case staging      // api.stg.deuna.io
    case sandbox      // api.sandbox.deuna.io
    case production   // api.deuna.io
}
```

## 9. JavaScript Bridge Communication

### 9.1 Registered Handlers

These are the handlers registered in the `WKScriptMessageHandler` to receive messages from the webview.

> **Warning**: These names are used in the webview to send messages to the native code. If deleted or renamed, the event listening will not work.

```swift
public enum WebViewUserContentControllerNames {
    public static let remoteJs = "remoteJs"        // Remote functions
    public static let consoleLog = "consoleLog"    // Console logs
    public static let xprops = "xprops"            // Widget events
    public static let deuna = "deuna"              // DEUNA channel
    public static let saveBase64Image = "saveBase64Image" // Used to save webView screenshots
    public static let closeWindow = "closeWindow"  // Used to listen when window.close() function is called
}
```

### 9.2 Available Remote Functions
The JavaScript bridge allows the webview to call JavaScript functions defined in the widget using JavaScript injection.

| Function | Description |
|----------|-------------|
| `setCustomStyle(...)` | Apply custom styles |
| `refetchOrder(...)` | Reload order data |
| `isValid()` | Validate form data |
| `submit()` | Submit payment form |
| `getWidgetState()` | Get widget state |
| `takeScreenshot()` | Inject JavaScript function used to capture webview screenshots |

---

## 10. Error Handling

### 10.1 Payments Error Structure
Structure used to represent errors for the Payment Widget, Checkout Widget, NextAction Widget & Voucher Widget.

```swift
public struct PaymentsError {
    public let type: ErrorType
    public let metadata: ErrorMetadata?
    public let order: [String: Any]?

    public struct ErrorMetadata {
        public let code: String
        public let message: String
    }

    public enum ErrorType: Error {
        case noInternetConnection
        case invalidOrderToken
        case initializationFailed
        case errorWhileLoadingTheURL
        case orderNotFound
        case orderCouldNotBeRetrieved
        case paymentError
        case userError
        case unknownError
    }
}
```

### 10.2 Elements Error Structure
Structure used to represent errors for the Vault Widget & Click to Pay Widget.

```swift
struct ElementsError {
    public let type: ErrorType
    public let metadata: ErrorMetadata?
    
    public struct ErrorMetadata {
        public let code: String
        public let message: String
    }
    
    public enum ErrorType: String {
        case noInternetConnection
        case initializationFailed
        case userError
        case invalidUserToken
        case unknownError
        case vaultSaveError
        case vaultFailed
    }
}
```

---

## 11. Local development
Follow the next video to learn how to set up the local development environment: 


## 12. Publication flow
The publication flow can be found in the next link [Publication Flow](https://www.notion.so/deuna/iOS-SDK-publication-flow-7a21e4edf62b4b1c969c745e483da469)

## 11. Key Questions for Knowledge Transfer

### Answered in this document:

| Question | Answer |
|----------|--------|
| What is the SDK architecture? | WebView-based with Delegate/Callback pattern |
| How are APM flows handled? | ExternalUrlHandler + Safari/WebView |
| How does polling work? | Delegated to web frontend, SDK only listens to events |
| What external dependencies are used? | deuna-ios-client, WebKit, SafariServices |
| How is vaulting handled? | Elements widget with userToken/userInfo |

---

## 12. Example Apps

The SDK includes example applications to demonstrate integration patterns.

### 12.1 Available Examples

```
Examples/
├── deuna-embedded-widgets/           # SwiftUI embedded widgets example
├── deuna-show-widgtes-in-modal/      # Modal presentation example
└── checkout-web-wrapper/             # Web wrapper example
```

| Example | Description | Integration Type |
|---------|-------------|------------------|
| `deuna-embedded-widgets` | Demonstrates embedding DEUNA widgets directly in SwiftUI views | Embedded (SwiftUI) |
| `deuna-show-widgtes-in-modal` | Demonstrates presenting widgets as modal page sheets | Modal (UIKit/SwiftUI) |
| `checkout-web-wrapper` | Web wrapper implementation example | WebView wrapper |

### 12.2 Opening Examples in Xcode

1. Navigate to the example directory:
   ```
   Examples/deuna-embedded-widgets/
   ```
2. Open the `.xcodeproj` file in Xcode:
   ```
   deuna-embedded-widgets.xcodeproj
   ```
3. Select a simulator or device target
4. Build and run (⌘ + R)

> **Note:** By default, the examples use the SDK from **Swift Package Manager** (remote dependency).

### 12.3 Testing Local SDK Changes

To test local changes to the SDK in the example apps, you need to replace the remote SPM dependency with a local package reference.

**Steps to use local SDK:**

1. **Open the example project** in Xcode

2. **Remove the remote DeunaSDK package:**
   - Go to the project settings (click on the project in the navigator)
   - Select the project (not the target)
   - Go to **Package Dependencies** tab
   - Find `DeunaSDK` in the list
   - Select it and click the **-** button to remove

3. **Add the local SDK package:**
   - Go to **File → Add Package Dependencies...**
   - Click **Add Local...**
   - Navigate to the SDK root directory:
     ```
     /path/to/deuna-sdk-ios/
     ```
   - Select the folder containing `Package.swift`
   - Click **Add Package**

4. **Verify the local package is linked:**
   - Go to the target's **General** tab
   - Under **Frameworks, Libraries, and Embedded Content**
   - Ensure `DeunaSDK` is listed

5. **Build and run** the example app with your local SDK changes

---

*Document generated: January 2026*
*Version: 1.0*

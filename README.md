![](https://d-una-one.s3.us-east-2.amazonaws.com/gestionado_por_d-una.png)
# DeunaSDK Documentation
[![License](https://img.shields.io/github/license/deuna-developers/deuna-sdk-ios?style=flat-square)](https://github.com/deuna-developers/deuna-sdk-ios/LICENSE)
[![Platform](https://img.shields.io/badge/platform-ios-blue?style=flat-square)](https://github.com/deuna-developers/deuna-sdk-ios#)

## Introduction

DeunaSDK is a Swift-based SDK designed to facilitate integration with the DEUNA. This SDK provides a seamless way to initialize payments, handle success, error, and close actions, and manage configurations.

Get started with our [📚 integration guides](https://docs.deuna.com/docs/integraciones-del-ios-sdk) and [example projects](#examples)



## Installation

### Swift Package Manager

You can install DeunaSDK using Swift Package Manager by adding the following dependency to your `Package.swift` file:

    dependencies: [
        .package(url: "https://github.com/orgs/deuna-developers/DeunaSDK.git", from: "1.0.0")
    ] 

Or, in Xcode:

1.  Go to `File` > `Swift Packages` > `Add Package Dependency`.
2.  Enter `https://github.com/orgs/deuna-developers/DeunaSDK.git` as the package repository URL.
3.  Choose a minimum version of `1.0.0`.

### Examples

- [Prebuilt UI](Examples/basic-integration) (Recommended)
  - This example demonstrates how to build a payment flow using [`PaymentWidget`](https://docs.deuna.com/docs/widget-payments-and-fraud)

## Usage


### Configuration

Before using the SDK, you need to configure it with your API key, order token, user token, environment, element type, and close button configuration.

    DeunaSDK.config(
        apiKey: "YOUR_API_KEY",
        orderToken: "YOUR_ORDER_TOKEN",
        userToken: "YOUR_USER_TOKEN",
        environment: .production, // or .development
        elementType: .saveCard, // or .example
        closeButtonConfig: CloseButtonConfig() // Optional
        shouldPresentInModal: true || false // Defaults to false, if true the checkout will be opened in a modal sheet
    ) 

### Initializing Checkout

This method initializes the checkout process. It sets up the WebView, checks for internet connectivity, and loads the payment link.

**Parameters:**

-   **callbacks**: An instance of the `DeunaSDK.Callbacks` class, which contains closures that will be called on success, error, or when the WebView is closed.
    
-   **viewToEmbedWebView** (Optional): A `UIView` where the WebView should be embedded. If this parameter is not provided, the SDK will automatically select a view from the parent view controller to embed the WebView.

        let callbacks = DeunaSDK.Callbacks()
        callbacks.onsuccess = { message in 
            //Handle success case
        }
    
        callbacks.onError = { error in
            // Handle error case
            print(errr)
        }

        callbacks.onClose = { webView in
            // Handle close action
            print("Close")
        }
    
        // Providing a specific view for embedding the WebView
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 600))
        DeunaSDK.shared.initCheckout(callbacks: callbacks, viewToEmbedWebView: customView)

        // Without providing a view (SDK will select a view from the parent)
        DeunaSDK.shared.initCheckout(callbacks: callbacks)` 

**Note**: If `viewToEmbedWebView` is not provided, the SDK will automatically select a suitable view from the parent view controller to embed the WebView. This ensures that the WebView is always visible to the user during the checkout process.

### Overriding the Order Token

If you need to change the order token after the SDK has been configured, you can use the `setOrderToken` method.


`DeunaSDK.shared.setOrderToken(newOrderToken: "NEW_ORDER_TOKEN")` 

## Classes & Enums

### CloseButtonConfig

This class allows you to customize the appearance and position of the close button on the WebView.

## DeunaSDKError

`DeunaSDKError` is an enumeration that represents the possible errors that can occur during the SDK's operation. Each case in this enumeration provides a specific type of error, making it easier to handle and provide feedback to the user or developer.

### Cases:

1.  **noInternetConnection**:
    
    -   Description: This error is triggered when there's no available internet connection.
    -   Message: "No internet connection available."
2.  **checkoutInitializationFailed**:
    
    -   Description: This error occurs when the SDK fails to initialize the WebView. This could be due to various reasons, such as configuration issues or system-level restrictions.
    -   Message: "Failed to initialize the WebView."
3.  **orderNotFound**:
    
    -   Description: This error is raised when the SDK cannot find the specified order. This could be due to an incorrect order token or issues on the server side.
    -   Message: "Order not found."
4.  **unknownError(String)**:
    
    -   Description: This is a catch-all error case. If an error occurs that doesn't match any of the predefined cases, this error is used. It accepts a custom message as a parameter, allowing for more specific error descriptions.
    -   Message: The custom message provided when the error is raised.
#### Environment

An enumeration representing the environment in which the SDK operates. Possible values are `.development` and `.production`.

#### ElementType

An enumeration representing the type of element. Possible values are `.saveCard` and `.example`.

#### Callbacks

A nested class within `DeunaSDK` that allows you to set callbacks for success, error, and close actions.

### Logging

To enable or disable logging:

    DeunaSDK.shared.enableLogging() // To enable
    DeunaSDK.shared.disableLogging() // To disable` 

### Network Reachability

The SDK automatically checks for network availability before initializing the checkout process.

## Author
DUENA Inc.

## License
DEUNA's SDKs and Libraries are available under the MIT license. See the LICENSE file for more info.

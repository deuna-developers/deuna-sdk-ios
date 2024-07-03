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
        .package(url: "https://github.com/orgs/deuna-developers/DeunaSDK.git", from: "2.1.0")
    ] 

Or, in Xcode:

1.  Go to `File` > `Swift Packages` > `Add Package Dependency`.
2.  Enter `https://github.com/orgs/deuna-developers/DeunaSDK.git` as the package repository URL.
3.  Choose a minimum version of `2.0.0`.

### Examples

- [Prebuilt UI](Examples/basic-integration) (Recommended)
  - This example demonstrates how to build a payment flow using [`PaymentWidget`](https://docs.deuna.com/docs/widget-payments-and-fraud)

## Usage

First import the Deuna SDK

```swift
import DeunaSDK
```

### Initialization

To use the SDK you need to create one instance of `DeunaSDK`. There are 2 ways that you can create an instance of `DeunaSDK`:

1. Registing a singleton to use the same instance in any part of your code

    ```swift
    DeunaSDK.initialize(
        environment: .sandbox, // or .production based on your need
        publicApiKey: "YOUR_PUBLIC_API_KEY",
    )
    ```
    Now you can use the same instance of DeunaSDK using `DeunaSDK.shared`

    ```swift
    DeunaSDK.shared.initCheckout(...)
    ```

2. Instantiation

    ```swift
    class MyClass {
        let deunaSDK: DeunaSDK
    
        init {
            deunaSDK = DeunaSDK(
                environment: .sandbox,
                publicApiKey: "YOUR_PUBLIC_API_KEY",
            )
        }

        fun buy(){
            deunaSdk.initCheckout(...)
        }
    }
    ```




### Launch the Checkout

To launch the checkout process you must use the `initCheckout` function. It sets up the DEUNA widget, checks for internet connectivity, and loads the payment link.

**Parameters:**
-   **orderToken**: The token representing the order.
-   **callbacks**: An instance of the `CheckoutCallbacks` class, which contains closures that will be called on success, error, or when the DEUNA widget is closed.
-   **closeEvents**: A set of `CheckoutEvent` values specifying when to automatically close the checkout.

    > NOTE: By default, the DEUNA widget is only closed when the user presses the close button. You can use the `closeEvents` parameter to close the WebView without having to call the `closeCheckout` function.

    ```swift
    let deunaSDK: DeunaSDK = ....
    .
    .
    .

    let callbacks = CheckoutCallbacks(
        onSuccess: { _ in
           self.deunaSDK.closeCheckout()
           // show the success view
        },
        onError: { error in
            // handle the error
            self.deunaSDK.closeCheckout()
        },
        onClosed: {
            // DEUNA widget was closed
        },
        onCanceled: {
          // called when the paymenyt was canceled by user
          // Calling closeCheckout(...) is unnecessary here.
        },
        eventListener: { type, _ in
            // listen the checkout events
            if event == .changeCart || event == .changeAddress {
                self.deunaSDK.closeCheckout()
            }
        }
    )

    deunaSDK.initCheckout(
        orderToken: "YOUR_ORDER_TOKEN",
        callbacks: callbacks
    )  
    ```



### Launch the VAULT WIDGET

This method lauches the elements process. It sets up the Elements widget, checks for internet connectivity, and loads the elements link.

**Parameters:**
-   **userToken**: The token representing the user.
-   **callbacks**: An instance of the `ElementsCallbacks` class, which contains closures that will be called on success, error, or when the WebView is closed.
-   **closeEvents**: A set of `ElementsEvent` values specifying when to automatically close the checkout.

    > NOTE: By default, the VAULT widget modal is only closed when the user presses the close button. You can use the `closeEvents` parameter to close the WebView without having to call the `closeElements` function.

    ```swift
    let callbacks = ElementsCallbacks(
        onSuccess: { _ in
            self.deunaSDK.closeElements()
           // show the success view
        },
        onError: { error in
            // handle the error
            self.deunaSDK.closeElements()
        },
        onClosed: {
            // DEUNA widget was closed
        },
        onCanceled: {
          // called when the saving card process was canceled by user
          // Calling closeElements(...) is unnecessary here.
        },
        eventListener: { type, _ in
          // listen the elements events
        }
    )

    deunaSDK.initElements(
        userToken: "YOUR_USER_TOKEN",
        callbacks: callbacks
    )  
    ```



### Logging
To enable or disable logging:
```swift
DeunaLogs.isEnabled = false // or true
```

### Network Reachability

The SDK automatically checks for network availability before initializing the checkout process.


## FAQs
* ### How to get an **order token** ?
    To generate an order token, refer to our API documentation on our [API Referece](https://docs.deuna.com/reference/order_token)

* ### How to get an **user token** ?
    You'll need a registered user in DEUNA. Follow the instructions for ["User Registration"](https://docs.deuna.com/reference/users-register) in our API reference.

    Once you have a registered user, you can obtain an access token through a two-step process:

    **Request an OTP code**: Use our API for "[Requesting an OTP Code](https://docs.deuna.com/reference/request-otp)" via email.

    **Login with OTP code:** Use the retrieved code to "[Log in with OTP](https://docs.deuna.com/reference/login-with-otp)" and get an access token for your user.
    

## Author
DUENA Inc.

## License
DEUNA's SDKs and Libraries are available under the MIT license. See the LICENSE file for more info.

![](https://d-una-one.s3.us-east-2.amazonaws.com/gestionado_por_d-una.png)
# DeunaSDK Documentation
[![License](https://img.shields.io/github/license/deuna-developers/deuna-sdk-ios?style=flat-square)](https://github.com/deuna-developers/deuna-sdk-ios/LICENSE)
[![Platform](https://img.shields.io/badge/platform-ios-blue?style=flat-square)](https://github.com/deuna-developers/deuna-sdk-ios#)

## Introduction

DeunaSDK is a Swift-based SDK designed to facilitate integration with the DEUNA. This SDK provides a seamless way to initialize payments, handle success, error, and close actions, and manage configurations.

Get started with our [📚 integration guides](https://docs.deuna.com/docs/integracion-ios-sdk) and [Explore example app](https://github.com/deuna-developers/deuna-sdk-ios/tree/main/Examples/explore).

### Explore Example: Where To Start

If you are reviewing the sample app to understand SDK usage, start with:

1. [DeunaSDKService.swift](https://github.com/deuna-developers/deuna-sdk-ios/blob/main/Examples/explore/Explore/Data/Services/DeunaSDKService.swift): single entry point for direct DEUNA SDK calls.
2. [WidgetConfigBuilder.swift](https://github.com/deuna-developers/deuna-sdk-ios/blob/main/Examples/explore/Explore/Data/Services/WidgetConfigBuilder.swift): how embedded widget configuration is built.
3. [EmbeddedScreen.swift](https://github.com/deuna-developers/deuna-sdk-ios/blob/main/Examples/explore/Explore/Presentation/Screens/WidgetModes/EmbeddedScreen.swift): where `DeunaWidget` is rendered in embedded mode.


## Installation

### Swift Package Manager

Add the package in Xcode: **File › Add Package Dependencies** and enter:

```
https://github.com/deuna-developers/deuna-sdk-ios
```

Then add the products you need to your target:

```swift
// Package.swift
.product(name: "DeunaSDK", package: "deuna-sdk-ios"),

// Optional — only add the fraud providers you actually use:
// .product(name: "DeunaSDKCybersource", package: "deuna-sdk-ios"),
// .product(name: "DeunaSDKKount",        package: "deuna-sdk-ios"),
// .product(name: "DeunaSDKSift",         package: "deuna-sdk-ios"),
// .product(name: "DeunaSDKRiskified",    package: "deuna-sdk-ios"),
// .product(name: "DeunaSDKSignifyd",     package: "deuna-sdk-ios"),
```

### CocoaPods

```ruby
# Podfile

pod 'DeunaSDK/Core'

# Optional — only add the fraud providers you actually use:
# pod 'DeunaSDK/Cybersource'
# pod 'DeunaSDK/Kount'
# pod 'DeunaSDK/Sift'
# pod 'DeunaSDK/Riskified'
# pod 'DeunaSDK/Signifyd'
```

---

## Fraud Prevention — `generateFraudId`

`generateFraudId` collects a device fingerprint from one or more fraud providers and returns a base64-encoded string that you send to DEUNA during checkout.

Fraud provider SDKs are **optional and modular**. The core SDK ships with zero fraud dependencies — you only bundle what you use. Each provider is detected at runtime once its framework is linked; no initialization code is required.

### How it works

1. Add the product/subspec for each provider you need (see [Installation](#installation) above).
2. Call `generateFraudId` with the config for your providers — that is all.
3. Pass the returned `fraudId` string to your DEUNA order or session.

```swift
sdk.generateFraudId(params: [
    "CYBERSOURCE": [
        "orgId":      "your-org-id",
        "merchantId": "your-merchant-id",
    ],
]) { fraudId in
    guard let fraudId else { return }
    // send fraudId to your backend / DEUNA order API
}
```

> If a provider framework is not linked the SDK logs a warning and skips it — no crash.

---

### Cybersource (LexisNexis ThreatMetrix)

**Add the dependency**

```swift
// SPM
.product(name: "DeunaSDKCybersource", package: "deuna-sdk-ios")
```
```ruby
# CocoaPods
pod 'DeunaSDK/Cybersource'
```

**Call `generateFraudId`**

```swift
sdk.generateFraudId(params: [
    "CYBERSOURCE": [
        "orgId":      "<your-org-id>",       // required — provided by LexisNexis
        "merchantId": "<your-merchant-id>",  // required — used as session ID prefix
        // "fpServer": "h.online-metrix.net" // optional — default shown
    ]
]) { fraudId in
    print(fraudId ?? "nil")
}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `orgId` | String | ✅ | Organization ID provided by LexisNexis |
| `merchantId` | String | ✅ | Merchant ID — used as session ID prefix |
| `fpServer` | String | ❌ | Fingerprint server. Default: `h.online-metrix.net` |

> The SDK configures the ThreatMetrix singleton **once** per app lifecycle. Subsequent calls with a different `orgId` are ignored with a warning.

---

### Kount

**Add the dependency**

```swift
// SPM
.product(name: "DeunaSDKKount", package: "deuna-sdk-ios")
```
```ruby
# CocoaPods
pod 'DeunaSDK/Kount'
```

**Call `generateFraudId`**

```swift
sdk.generateFraudId(params: [
    "KOUNT": [
        "merchantId":  "<your-merchant-id>",  // required
        // "environment": "TEST"              // optional — "PRODUCTION" (default) or "TEST"
    ]
]) { fraudId in
    print(fraudId ?? "nil")
}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `merchantId` | String | ✅ | Merchant ID provided by Kount |
| `environment` | String | ❌ | `"PRODUCTION"` (default) or `"TEST"` |

> **Bundle size note:** KountSDK.xcframework adds ~5 MB to the device binary. Only include this subspec/product if you use Kount.

---

### Sift Science

**Add the dependency**

```swift
// SPM
.product(name: "DeunaSDKSift", package: "deuna-sdk-ios")
```
```ruby
# CocoaPods
pod 'DeunaSDK/Sift'
```

**Call `generateFraudId`**

```swift
sdk.generateFraudId(params: [
    "SIFT": [
        "accountId": "<your-account-id>",  // required
        "beaconKey": "<your-beacon-key>",  // required
    ]
]) { fraudId in
    print(fraudId ?? "nil")
}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `accountId` | String | ✅ | Sift Science account ID |
| `beaconKey` | String | ✅ | Sift Science beacon key |

---

### Riskified

**Add the dependency**

```swift
// SPM
.product(name: "DeunaSDKRiskified", package: "deuna-sdk-ios")
```
```ruby
# CocoaPods
pod 'DeunaSDK/Riskified'
```

**Call `generateFraudId`**

```swift
sdk.generateFraudId(params: [
    "RISKIFIED": [
        "storeDomain": "yourstore.com",  // required — no https://
    ]
]) { fraudId in
    print(fraudId ?? "nil")
}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `storeDomain` | String | ✅ | Store domain registered with Riskified (no `https://`) |

---

### Signifyd

Signifyd uses ThreatMetrix device fingerprinting under the hood (TMXProfiling + TMXProfilingConnections). Add the Signifyd product/subspec and the SDK will configure and profile automatically.

**Swift Package Manager**
```swift
.product(name: "DeunaSDKSignifyd", package: "deuna-sdk-ios")
```

**CocoaPods**
```ruby
pod 'DeunaSDK/Signifyd'
```

**Call `generateFraudId`**
```swift
sdk.generateFraudId(params: [
    "SIGNIFYD": [
        "orgId":    "w2tc05aa",          // org ID provided by Signifyd
        "fpServer": "imgs.signifyd.com", // optional, this is the default
    ],
]) { fraudId in
    print(fraudId ?? "nil")
}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `orgId` | String | ✅ | Organization ID provided by Signifyd |
| `fpServer` | String | ❌ | Fingerprint server FQDN (default: `imgs.signifyd.com`) |

---

### Multiple providers simultaneously

All providers in the same `params` dict run **in parallel**. The returned `fraudId` is a base64-encoded JSON map of each provider's session ID:

```swift
sdk.generateFraudId(params: [
    "CYBERSOURCE": [
        "orgId":      "my-org",
        "merchantId": "my-merchant",
    ],
    "SIFT": [
        "accountId": "my-account",
        "beaconKey": "my-key",
    ],
]) { fraudId in
    // fraudId = base64({ "CYBERSOURCE": "uuid-1", "SIFT": "uuid-2" })
}
```

---

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

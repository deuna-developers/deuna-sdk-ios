# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.1.0]
- Added support for the new payment widget. Check the implementation [here](https://docs.deuna.com/docs/integracion-payment-widget-ios)
    

## [2.0.3]
- Fixed sandbox domains.


## [2.0.2]
- Fixed loading animation during webview loading process.
- Updated deuna-ios-client to `1.4.11`.

## [2.0.1]
- Fixed bad elements URL on production.

## [2.0.0]

* **Renamed classes and enums:**
  * `Callbacks` to `CheckoutCallbacks`
  * `OrderEventResponse` to `CheckoutResponse`
  * `ElementEventResponse` to `ElementsResponse`
  * `ElementEventResponseData` to `ElementsResponseData`
  * `ElementEventResponseUser` to `ElementsResponseUser`
  * `ElementEventResponseOrderMetadata` to `ElementsResponseOrderMetadata`
  * `CheckoutEventType` to `CheckoutEvent`
  
- Removed `presentInModal` and `showCloseButton` params in `initCheckout` and `initElements` functions.


## [1.0.1] - 2023-11-17

### Changed
- Deuna SDK location change in sample project

## [1.0.0] - 2023-11-15

### Changed

- Initial release

## Authors

* **Deuna** - *Initial work* - [Deuna]

## License

This project is a private property license.

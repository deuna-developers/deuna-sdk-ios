# SDK Integration Map

## Where DEUNA SDK is used directly
- `Data/Services/DeunaSDKService.swift` (single entry point for all SDK calls)
- `Data/Services/WidgetConfigBuilder.swift`
- `Data/Services/WidgetDefinitions.swift`
- `Data/Services/WidgetCallbacksFactory.swift`

## Embedded widgets
- `Data/Services/WidgetConfigBuilder.swift` is the best file to understand how embedded widget
  configurations are built per widget type.

## What is not SDK integration
- `Data/*`: API calls and persistence for sample app UX.
- `Presentation/*`: UI screens and user interaction.

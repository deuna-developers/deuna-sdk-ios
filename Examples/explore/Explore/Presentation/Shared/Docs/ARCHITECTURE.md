# Explore Architecture

Explore is organized in four clear layers:

- `Domain`: entities, repositories, and use-cases.
- `Data`: services and repository implementations.
- `Presentation`: shared ui, screens, and routing.

If you are integrating DEUNA SDK, start at:
1. `Data/Services/DeunaSDKService.swift`
2. `Data/Services/WidgetConfigBuilder.swift`
3. `Data/Services/WidgetCallbacksFactory.swift`
4. `Presentation/Screens/ExploreCoordinator.swift`

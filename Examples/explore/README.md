# Explore (iOS SDK Example)

`Explore` is the official iOS example app for DEUNA SDK integrations.

## What it includes
- Embedded and modal widget flows in one app.
- A configuration drawer to switch environment, widget type, and runtime options.
- UI integration tests in `DeunaSDKIntegrationTests`.

## Run locally
```bash
cd Examples/explore
xcodebuild -project Explore.xcodeproj -scheme Explore -destination "platform=iOS Simulator,name=iPhone 16" build
```

## Run integration tests
```bash
cd Examples/explore
xcodebuild test \
  -project Explore.xcodeproj \
  -scheme Explore \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:DeunaSDKIntegrationTests
```

## Notes
- This example does **not** support Docker-based execution.
- This example does **not** include End-to-End Preproduction specific setup.

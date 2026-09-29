Pod::Spec.new do |s|
  s.name             = 'DeunaSDK'
  s.version          = '2.12.6'
  s.summary          = 'SDK de Deuna para iOS'
  s.description      = <<-DESC
    SDK oficial de Deuna para integrar pagos y funcionalidades en aplicaciones iOS.
  DESC

  s.homepage         = 'https://github.com/deuna-developers/deuna-sdk-ios.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'deuna' => 'dmorocho@deuna.com' }
  s.source           = { :git => 'https://github.com/deuna-developers/deuna-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_versions        = ['5.0']
  s.static_framework      = true

  # ── Core subspec ─────────────────────────────────────────────────────────────
  # Contains the full SDK with zero fraud provider dependencies.
  # Fraud providers are detected at runtime via NSClassFromString.
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = [
      'Sources/DeunaSDK/**/*.swift',
      'Sources/_DeunaSDKObjCBridge/**/*.{h,m}',
    ]
    core.exclude_files = [
      'Sources/DeunaSDK/Vendor/**/*',
    ]
    core.public_header_files = 'Sources/_DeunaSDKObjCBridge/include/*.h'
    core.dependency 'DEUNAClient', '~> 1.0.0'
  end

  # ── Optional fraud provider subspecs ────────────────────────────────────────
  # Add the subspec(s) matching the providers you pass to generateFraudId.
  # No code changes required — DeunaSDK finds the linked framework at runtime.

  # pod 'DeunaSDK/Cybersource'
  s.subspec 'Cybersource' do |sub|
    sub.dependency 'DeunaSDK/Core'
    sub.vendored_frameworks = [
      'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfiling.xcframework',
      'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfiling-companion.xcframework',
      'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfilingConnections.xcframework',
      'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfilingConnections-companion.xcframework',
    ]
  end

  # pod 'DeunaSDK/Kount'
  s.subspec 'Kount' do |sub|
    sub.dependency 'DeunaSDK/Core'
    sub.vendored_frameworks = [
      'Sources/DeunaSDK/Vendor/Kount/KountSDK.xcframework',
    ]
  end

  # pod 'DeunaSDK/Sift'
  s.subspec 'Sift' do |sub|
    sub.dependency 'DeunaSDK/Core'
    sub.dependency 'Sift', '~> 2.2.5'
  end

  # pod 'DeunaSDK/Riskified'
  s.subspec 'Riskified' do |sub|
    sub.dependency 'DeunaSDK/Core'
    sub.dependency 'RiskifiedBeacon', '~> 1.2.9'
  end

  # pod 'DeunaSDK/Signifyd'
  s.subspec 'Signifyd' do |sub|
    sub.dependency 'DeunaSDK/Core'
    sub.vendored_frameworks = [
      'Sources/DeunaSDK/Vendor/Signifyd/TMXProfiling.xcframework',
      'Sources/DeunaSDK/Vendor/Signifyd/TMXProfilingConnections.xcframework',
    ]
  end

  # pod 'DeunaSDK/Accertify'
  s.subspec 'Accertify' do |sub|
    sub.dependency 'DeunaSDK/Core'
    sub.vendored_frameworks = [
      'Sources/DeunaSDK/Vendor/Accertify/InMobileMME.xcframework',
    ]
  end

  # pod 'DeunaSDK/MercadoPago'
  s.subspec 'MercadoPago' do |sub|
    sub.dependency 'DeunaSDK/Core'
    sub.source_files = [
      'Sources/DeunaSDK/Vendor/MercadoPago/Swift/**/*.swift',
      'Sources/DeunaSDK/Vendor/MercadoPago/ObjCBridge/**/*.{h,m}',
    ]
    sub.public_header_files = 'Sources/DeunaSDK/Vendor/MercadoPago/ObjCBridge/include/*.h'
  end
end

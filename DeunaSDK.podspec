Pod::Spec.new do |s|
  s.name             = 'DeunaSDK'
  s.version          = '2.11.0-beta.1'
  s.summary          = 'SDK de Deuna para iOS'
  s.description      = <<-DESC
    SDK oficial de Deuna para integrar pagos y funcionalidades en aplicaciones iOS.
  DESC

  s.homepage         = 'https://github.com/deuna-developers/deuna-sdk-ios.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'deuna' => 'dmorocho@deuna.com' }
  s.source           = { :git => 'https://github.com/deuna-developers/deuna-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_versions   = ['5.0']
  
  s.source_files     = 'Sources/DeunaSDK/**/*.{h,m,swift}'
  s.vendored_frameworks = [
    'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfiling.xcframework',
    'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfiling-companion.xcframework',
    'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfilingConnections.xcframework',
    'Sources/DeunaSDK/Vendor/Cybersource/RLTMXProfilingConnections-companion.xcframework'
  ]

  s.dependency 'DEUNAClient', '~> 1.0.0'
  s.dependency 'RiskifiedBeacon', '~> 1.2.9'
end

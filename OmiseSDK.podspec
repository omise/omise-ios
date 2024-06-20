Pod::Spec.new do |s|
  s.name             = 'OmiseSDK'
  s.version          = '4.28'
  s.summary          = 'Opn Payments iOS SDK.'
  s.description      = <<-DESC
                       Opn Payments is a payment service provider operating in Thailand, Japan, and Singapore. Opn Payments provides a set of APIs that help merchants of any size accept payments online.

The Opn Payments iOS SDK provides bindings for tokenizing credit cards and accepting non-credit-card payments using the Opn Payments API, allowing developers to safely and easily accept payments within apps.
                       DESC
  s.homepage         = 'https://github.com/omise/omise-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrei Solovev' => 'andrei@opn.ooo' }
  s.source           = { :git => 'https://github.com/omise/omise-ios.git', :branch => 'feature/v4_cocoapods' }
# :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'OmiseSDK/Sources/**/*.{swift,h,m}'
  s.public_header_files = 'OmiseSDK/Sources/**/*.h'
#  s.exclude_files = 'OmiseSDK/Info.plist'

  s.resource_bundles = {
    'OmiseSDK' => ['OmiseSDK/Resources/**/*']
  }

  s.swift_version = '5.0'

end

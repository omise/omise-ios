Pod::Spec.new do |s|
  s.name             = 'omise-ios'
  s.version          = '1.0.1'
  s.summary          = 'Client library for the Omise API'
  s.description      = <<-DESC
    omise-ios is a Cocoa library for managing payment authorization tokens
    and stored credit card details with the Omise API.
  DESC

  s.homepage         = 'https://github.com/omise/omise-ios'
  s.social_media_url = 'https://twitter.com/omise'
  s.author           = { 'Omise' => 'support@omise.co' }
  s.license          = 'MIT'
  s.source           = { :git => 'https://github.com/omise/omise-ios.git',
                         :tag => "v#{s.version}" }

  s.platform     = :ios, '5.0'

  s.source_files        = 'Omise-iOS_SDK/Omise-iOS/OmiseLib/*.{h,m}'
  s.public_header_files = 'Omise-iOS_SDK/Omise-iOS/OmiseLib/*.h'
  s.frameworks = ['UIKit']
end

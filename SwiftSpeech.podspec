Pod::Spec.new do |s|
    s.name             = 'SwiftSpeech'
    s.version          = '0.9.3'
    s.summary          = 'Recognize your user\'s voice elegantly without having to figure out authorization and audio engines.'
    s.homepage         = 'https://github.com/Cay-Zhang/SwiftSpeech'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Cay Zhang' => 'cayzhang@protonmail.com' }
    s.source           = { :git => 'https://github.com/Cay-Zhang/SwiftSpeech.git', :tag => "v#{s.version}" }
    s.ios.deployment_target = '13.0'
    s.swift_version = '5.1'
    s.source_files = 'Sources/SwiftSpeech/**/*'
end

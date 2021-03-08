Pod::Spec.new do |s|
  s.name             = 'BatchATInternetDispatcher'
  s.version          = '1.1.0'
  s.summary          = 'Batch.com Events Dispatcher AT Internet implementation.'

  s.description      = <<-DESC
  A ready-to-go event dispatcher for AT Internet. Requires the Batch iOS SDK.
                       DESC

  s.homepage         = 'https://batch.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Batch.com' => 'support@batch.com' }
  s.source           = { :git => 'https://github.com/BatchLabs/Batch-iOS-atinternet-dispatcher.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.platforms = {
    "ios" => "8.0"
  }
  s.swift_version = '5.0'

  s.requires_arc = true
  s.static_framework = true
  
  s.dependency 'ATInternet-Apple-SDK/Tracker', '>=2.0'
  s.dependency 'Batch', '~> 1.17'

  s.source_files = 'BatchATInternetDispatcher/Classes/**/*'
end

Pod::Spec.new do |s|
  s.name             = 'statistic'
  s.version          = '1.0.0'
  s.summary          = 'h5x statistic'

  s.homepage         = 'https://github.com/h5x-projects/h5x-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'laole918' => 'laole918@qq.com' }
  s.source           = { :git => 'https://github.com/h5x-projects/h5x-ios.git', :tag => s.version.to_s }

  s.platform         = :ios, '9.0'
  s.requires_arc     = true

  s.source_files = 'src/**/*.{h,m}'
  s.resources = 'src/**/*.{xib,png}'
  s.dependency 'library', '~> 1.0.0'
  s.dependency 'Flurry-iOS-SDK/FlurrySDK'
end

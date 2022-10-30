# Uncomment the next line to define a global platform for your project
# CocoaPods官方库
source 'https://github.com/CocoaPods/Specs.git'
# 清华大学镜像库，如果上面库无法加载请使用下面镜像
#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

platform :ios, '9.0'

workspace 'AA Simulator'
project 'AA Simulator'

target 'AA Simulator' do
  pod 'library', :path => 'library'
  pod 'fusion', :path => 'plugins/fusion'
  pod 'Flurry-iOS-SDK/FlurrySDK'
  project 'AA Simulator'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end

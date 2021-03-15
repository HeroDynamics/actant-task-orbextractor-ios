# Uncomment this line to define a global platform for your project
platform :ios, '14.1'

# Uncomment this line if you're using Swift
use_frameworks!

workspace 'ActantORB'

target 'ActantORB' do
    project 'ActantORB/ActantORB.xcodeproj'

    # https://cocoapods.org/pods/OpenCV2
    # https://github.com/opencv/opencv
    pod 'OpenCV2', '~> 3.4'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Forces the minimum to be 14.1 as that's our last deployment target, and new xcode build tools
      # give warnings in Xcode 12
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 14.1
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.1'
      end

      # Let's disable lint validation of double quotes in .h files.
      # In Xcode 12 this setting is enabled by default => so, we get compilation errors
      # in Pods which have not been migrated to Xcode 12 yet.
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
  end
end


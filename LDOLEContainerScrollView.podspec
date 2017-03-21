#
#  Be sure to run `pod spec lint LDOLEContainerScrollView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "LDOLEContainerScrollView"
  s.version      = "0.1.0"
  s.summary      = "A UIStackView like ContainerScrollView, support multiple ScrollViews horizentol layout."
  s.homepage     = "http://EXAMPLE/LDOLEContainerScrollView"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "荣英杰" => "yjrong@corp.netease.com" }

  # s.platform     = :ios
  s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://git.ms.netease.com/neteaselottery/LDOLEContainerScrollView.git", :tag => s.version.to_s }


  s.source_files  = "LDOLEContainerScrollView/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.public_header_files = 'LDOLEContainerScrollView/HYGDotSegcontrol.h',
						  'LDOLEContainerScrollView/LDPageContainerScrollView.h',
						  'LDOLEContainerScrollView/OLEContainerScrollViewContentView.h','LDOLEContainerScrollView/OLEContainerScrollView.h'

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  #s.dependency "LDCPPullToReload", "~> 0.3.7"
  s.dependency "MJRefresh"  
  s.dependency "HMSegmentedControl"
end

platform :ios, '9.0'
inhibit_all_warnings!

target 'Quickstart' do
  use_frameworks!
  pod 'HyperTrackCore', :git => 'https://github.com/hypertrack/core-ios-sdk.git', :commit => 'c7554a7e9664b4c0c58de0c635ade83683bb0b3b'
end

pre_install do |installer|
  installer.analysis_result.specifications.each do |s|
    s.swift_version = '4.0' unless s.swift_version
  end
end

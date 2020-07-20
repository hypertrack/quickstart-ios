platform :ios, '11.0'
inhibit_all_warnings!

target 'Quickstart' do
  use_frameworks!
  pod 'HyperTrack', '4.2.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "HyperTrack"
      target.build_configurations.each do |config|
        if config.name == "Debug"
          config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = "DEBUG HYPERTRACK"
        end
      end
    end
  end
end

platform :ios, '11.0'
inhibit_all_warnings!

target 'Quickstart' do
  use_frameworks!
  pod 'HyperTrack', '3.7.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['GRDB.swift'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end

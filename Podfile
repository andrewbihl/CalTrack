platform :ios, '10.0'
use_frameworks!

target 'CalTrack' do
pod 'KeychainAccess', :git => 'https://github.com/kishikawakatsumi/KeychainAccess.git'
pod 'RealmSwift'
pod 'Whisper', :git => 'https://github.com/hyperoslo/Whisper.git'
pod 'NVActivityIndicatorView'
pod 'GoogleMaps', '2.3.1'
pod 'GooglePlaces', '2.3.1'
pod 'Firebase/Core'
pod 'Firebase/AdMob'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase/Messaging'
pod 'Fabric'
pod 'Crashlytics'
pod 'Google-Mobile-Ads-SDK'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

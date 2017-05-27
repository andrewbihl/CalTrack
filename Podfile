platform :ios, '10.0'
use_frameworks!

target 'CalTrack' do
pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git'
pod 'KeychainAccess', :git => 'https://github.com/kishikawakatsumi/KeychainAccess.git'
pod 'RealmSwift'
pod 'Whisper', :git => 'https://github.com/hyperoslo/Whisper.git'
pod 'NVActivityIndicatorView'
pod 'Instructions', :git => 'https://github.com/ephread/Instructions.git'
pod 'GoogleMaps'
pod 'GooglePlaces'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

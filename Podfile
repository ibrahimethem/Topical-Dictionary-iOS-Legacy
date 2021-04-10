# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
end

target 'Topical Dictionary' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Topical Dictionary

  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Analytics'
  pod 'FirebaseFirestoreSwift'
  pod 'Google-Mobile-Ads-SDK'
  pod 'FBSDKLoginKit'
  pod 'GoogleSignIn'

end

platform :ios, '12.0'

def testing_pods
  pod 'Quick'
  pod 'Nimble', '~> 7.1.3'
end

target 'PhotoWall' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PhotoWall
  pod 'AWSS3', '~> 2.6.26'
  pod 'Alamofire'
  pod 'PromiseKit/CorePromise', '~> 6.0'
  pod 'PromiseKit/Alamofire', '~> 6.0'
  pod 'PromiseKit/CoreLocation', '~> 6.0'
  pod 'GoogleSignIn'
  # Note: Using a specific commit form PKHUD until they release 5.2 which should support Swift 4.2
  pod 'PKHUD', :git => 'https://github.com/pkluz/PKHUD.git', :commit => 'f80fac74f0'
  pod 'HockeySDK', :subspecs => ['CrashOnlyLib']

  target 'PhotoWallTests' do
    inherit! :search_paths
    # Pods for testing
    testing_pods
  end
end

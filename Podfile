# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GeometricWeather' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GeometricWeather
  
  # moya.
  pod 'Moya', '~> 15.0'
  pod 'Moya/RxSwift', '~> 15.0'
  pod 'Moya/ReactiveSwift', '~> 15.0'
  
  # snapkit.
  pod 'SnapKit', '~> 5.0.0'
  
  # needle.
  pod 'NeedleFoundation'
  
  # ui.
  pod 'JXMovableCellTableView'
  pod 'UICountingLabel'

end

# target 'GeometricWeatherWidgetExtension' do
#   # Comment the next line if you don't want to use dynamic frameworks
#   use_frameworks!
#
#   # Pods for GeometricWeatherWidgetExtension
#
# end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
               end
          end
   end
end

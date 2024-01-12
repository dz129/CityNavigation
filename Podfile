# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CityNavigation' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'MapboxSearchUI', ">= 1.0.0-rc.8", "< 2.0"
  pod 'MapboxNavigation', '~> 2.17'
  # Pods for CityNavigation

  target 'CityNavigationTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CityNavigationUITests' do
    # Pods for testing
  end

end
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      end
    end
  end
end

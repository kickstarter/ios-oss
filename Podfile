# Resolve react_native_pods.rb with node to allow for hoisting
require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
end

def react_native_with_expo
  # Expo requires
  require File.join(File.dirname(`node --print "require.resolve('expo/package.json')"`), "scripts/autolinking")
   
  # Need to be added inside the target block
  use_expo_modules!
  
  config_command = [
    'node',
    '--no-warnings',
    '--eval',
    'require(require.resolve("expo-modules-autolinking", { paths: [require.resolve("expo/package.json")] }))(process.argv.slice(1))',
    'react-native-config',
    '--json',
    '--platform',
    'ios'
  ]
  config = use_native_modules!(config_command)
  return config
end

target 'Kickstarter-iOS' do
  config = react_native_with_expo

  use_react_native!(
    :path => config[:reactNativePath],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}"
  )
end

target 'Kickstarter-Framework-iOS' do
  config = react_native_with_expo

  use_react_native!(
    :path => config[:reactNativePath],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}"
  )

  post_install do |installer|
    # https://github.com/facebook/react-native/blob/main/packages/react-native/scripts/react_native_pods.rb#L197-L202
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false,
      # :ccache_enabled => true
    )
  end
end

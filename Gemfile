# Gemfile

source 'https://rubygems.org'

gem 'aws-sdk-s3'
gem 'danger'
gem 'danger-swiftformat'
gem 'danger-swiftlint'
gem 'fastlane'
gem 'xcode-install'
gem 'json'
gem 'plist'
gem 'slather'

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

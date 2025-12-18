#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'plist'
require 'aws-sdk-s3'

#
# Configure AWS SDK to use the system trust store provided in CI to avoid SSL
# verification failures when talking to S3.
#
Aws.config.update(
  ssl_ca_bundle: ENV['SSL_CERT_FILE'],
  ssl_ca_directory: ENV['SSL_CERT_DIR']
)
ENV['AWS_CA_BUNDLE'] ||= ENV['SSL_CERT_FILE']

#
# Interfacing with the builds bucket on S3
#

def bucket_name
  'ios-ksr-builds'
end

def bucket
   @bucket ||= Aws::S3::Bucket.new(bucket_name)
end

def current_builds
  @current_builds ||= YAML::load(bucket.object('builds.yaml').get.body.read)
end

#
# Script
#

previous_changelog = current_builds.last['changelog']
current_changelog_from_fastlane = File.read('.FASTLANE_RELEASE_NOTES.tmp')

file_name = '.RELEASE_NOTES.tmp'
File.delete(file_name) if File.exist?(file_name)
File.open(file_name, 'w') do |f|
  f.write(current_changelog_from_fastlane)
  f.write(previous_changelog
    .split("\n")
    .map {|line| "# #{line}"}
    .join("\n")
  )
end

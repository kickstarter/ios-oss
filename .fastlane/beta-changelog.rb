#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'plist'
require 'aws-sdk-s3'

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
File.delete(file_name) if File.exists?(file_name)
File.open(file_name, 'w') do |f|
  f.write(current_changelog_from_fastlane)
  f.write(previous_changelog
    .split("\n")
    .map {|line| "# #{line}"}
    .join("\n")
  )
end

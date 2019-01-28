#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'plist'
require 'fog-aws'

#
# Interfacing with the builds bucket on S3
#

def fog
  @fog ||= Fog::Storage.new({
    provider:              'AWS',
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID']
  })
end

def bucket_name
  'ios-ksr-builds'
end

def bucket
  @bucket ||= fog.directories.new(key: bucket_name)
end

def current_builds
  @current_builds ||= YAML::load(bucket.files.get('builds.yaml').body)
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

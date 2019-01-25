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
# Parsing app plist
#

def plist_path
  @plist_path ||= File.join('./../', 'Kickstarter-iOS', 'Info.plist')
end

def plist
  @plist ||= Plist::parse_xml(plist_path)
end

def plist_version
  plist["CFBundleShortVersionString"]
end

def plist_build
  plist["CFBundleVersion"].to_i
end

#
# Library
#
def strip_commented_lines(str)
  str.split("\n").select {|line| line.strip[0] != '#'}.join("\n")
end

#
# Script
#

file_name = '.RELEASE_NOTES.tmp'
changelog = strip_commented_lines(File.read(file_name)).strip

build = {
  'build' => plist_build,
  'changelog' => changelog,
}

bucket.files.create({
  key: 'builds.yaml',
  body: (current_builds.select {|b| b[:build] != plist_build} + [build]).to_yaml,
  public: false
}).save

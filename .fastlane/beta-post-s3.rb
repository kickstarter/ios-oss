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
# Parsing app plist
#

def plist_path
  @plist_path ||= begin
    root = File.dirname(File.dirname(__FILE__))
    File.join(root, 'Kickstarter-iOS', 'Info.plist')
  end
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

bucket.put_object({
  key: 'builds.yaml',
  body: (current_builds.select {|b| b[:build] != plist_build} + [build]).to_yaml,
  public: false
})

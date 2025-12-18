#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'plist'
require 'aws-sdk-s3'

#
# Configure AWS SDK to use the system trust store provided in CI to avoid SSL
# verification failures when talking to S3. Fall back to the macOS system paths
# used on CircleCI if the env vars are not present.
#
ca_bundle = ENV['SSL_CERT_FILE'].to_s.empty? ? '/etc/ssl/cert.pem' : ENV['SSL_CERT_FILE']
ca_dir = ENV['SSL_CERT_DIR'].to_s.empty? ? '/etc/ssl/certs' : ENV['SSL_CERT_DIR']
Aws.config.update(
  ssl_ca_bundle: ca_bundle,
  ssl_ca_directory: ca_dir
)
ENV['AWS_CA_BUNDLE'] ||= ca_bundle

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

bucket.put_object({
  key: 'builds.yaml',
  body: (current_builds.select {|b| b[:build] != plist_build} + [build]).to_yaml,
})

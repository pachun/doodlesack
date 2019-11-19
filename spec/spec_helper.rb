require 'simplecov'

if ENV["COVERAGE"]
  SimpleCov.minimum_coverage 100
  SimpleCov.start
end

require "doodlesack"

RSpec::Matchers.define :have_been_downloaded do
  match do |stubbed_download|
    expect(stubbed_download[:tempfile]).to have_received(:close)
    expect(FileUtils).to have_received(:mv).with(
      stubbed_download[:path],
      "ios_build.ipa",
    )
  end
end

DEFAULT_BUILD_LINK = "http://default.build.link"

def stub_build_download(build_link = DEFAULT_BUILD_LINK)
  fake_path = instance_double(String)
  fake_tempfile = double
  http_double = instance_double(URI::HTTP)
  allow(fake_tempfile).to receive(:path).and_return(fake_path)
  allow(URI).to receive(:parse).with(build_link).and_return(http_double)
  allow(http_double).to receive(:open).and_return(fake_tempfile)
  allow(fake_tempfile).to receive(:close)
  allow(FileUtils).to receive(:mv).with(fake_path, "ios_build.ipa")
  {
    tempfile: fake_tempfile,
    path: fake_path,
  }
end

def stub_expo_build(success, options = {})
  output = successful_expo_build_output(build_link: options[:build_link] || DEFAULT_BUILD_LINK)
  error = options[:error]
  allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
    output,
    error,
    success == :success ? 0 : 1,
  ])
end

def successful_expo_build_output(build_link:)
  <<~END_OF_STRING
    Checking if there is a build in progress...

    Publishing to channel 'default'...
    Building iOS bundle
    Building Android bundle
    Analyzing assets
    Uploading assets
    No assets changed, skipped.
    Processing asset bundle patterns:
    - /Users/pachun/code/doodles/**/*
    Uploading JavaScript bundles
    Published
    Your URL is

    https://exp.host/@pachun/doodles

    Checking if this build already exists...

    Build started, it may take a few minutes to complete.
    You can check the queue length at https://expo.io/turtle-status

    You can make this faster. 🐢
    Get priority builds at: https://expo.io/settings/billing

    You can monitor the build at

    https://expo.io/builds/09cc69ed-b8e3-4d03-b208-de683fde3860

    Waiting for build to complete. You can press Ctrl+C to exit.
    ✔ Build finished.
    Successfully built standalone app: #{build_link}
    ✨  Done in 540.25s.
  END_OF_STRING
end

def app_json_content_with_version(version)
  <<~END_OF_STRING
  {
    "expo": {
      "name": "doodles",
      "slug": "doodles",
      "privacy": "public",
      "sdkVersion": "35.0.0",
      "platforms": [
        "ios",
        "android",
        "web"
      ],
      "version": "#{version}",
      "orientation": "portrait",
      "icon": "./assets/icon.png",
      "splash": {
        "image": "./assets/splash.png",
        "resizeMode": "contain",
        "backgroundColor": "#ffffff"
      },
      "updates": {
        "fallbackToCacheTimeout": 0
      },
      "assetBundlePatterns": [
        "**/*"
      ],
      "ios": {
        "supportsTablet": true
      }
    }
  }
  END_OF_STRING
end

def write_app_json(with_version:)
  File.open("app.json", "w+") do |file|
    file.write(app_json_content_with_version(with_version))
  end
end

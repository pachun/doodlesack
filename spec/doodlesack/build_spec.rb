require "spec_helper"

describe Doodlesack::Build do
  let(:build_instance) { Doodlesack::Build.new }

  before(:each) do
    allow(Doodlesack::Build).to receive(:new).and_return(build_instance)
  end

  after(:each) do
    File.delete("app.json")
  end

  it "asks the user which type of update they're building for" do
    stub_expo_build
    write_app_json(with_version: "1.0.0")
    allow($stdin).to receive(:gets).and_return("\n")

    expect {
      Doodlesack::Build.run
    }.to output(
      /Which type of update\? \[major\|minor\|patch\] \(default is patch\)/
    ).to_stdout
  end

  context "the user responds to the build type question with 'major'" do
    it "bumps the major version number in app.json" do
      allow(build_instance).to receive(:print)
      stub_expo_build
      write_app_json(with_version: "1.0.0")
      allow($stdin).to receive(:gets).and_return("major\n")

      expect {
        Doodlesack::Build.run
      }.to change {
        File.read("app.json")
      }.from(
        app_json_content_with_version("1.0.0")
      ).to(
        app_json_content_with_version("2.0.0")
      )
    end
  end

  context "the user responds to the build type question with 'minor'" do
    it "bumps the minor version number in app.json" do
      allow(build_instance).to receive(:print)
      stub_expo_build
      write_app_json(with_version: "1.0.0")
      allow($stdin).to receive(:gets).and_return("minor\n")

      expect {
        Doodlesack::Build.run
      }.to change {
        File.read("app.json")
      }.from(
        app_json_content_with_version("1.0.0")
      ).to(
        app_json_content_with_version("1.1.0")
      )
    end
  end

  context "the user responds to the build type question with 'patch'" do
    it "bumps the patch version number in app.json" do
      allow(build_instance).to receive(:print)
      stub_expo_build
      write_app_json(with_version: "1.0.0")
      allow($stdin).to receive(:gets).and_return("patch\n")

      expect {
        Doodlesack::Build.run
      }.to change {
        File.read("app.json")
      }.from(
        app_json_content_with_version("1.0.0")
      ).to(
        app_json_content_with_version("1.0.1")
      )
    end
  end

  it "builds the ios app" do
    ok_exit_status = 0
    allow(build_instance).to receive(:print)
    write_app_json(with_version: "1.0.0")
    allow($stdin).to receive(:gets).and_return("patch\n")
    allow(Open3).to receive(:capture3).and_return(["", "", ok_exit_status])

    Doodlesack::Build.run

    expect(Open3).to have_received(:capture3).with("expo build:ios")
  end

  it "does not print an error" do
    ok_exit_status = 0
    write_app_json(with_version: "1.0.0")
    allow($stdin).to receive(:gets).and_return("patch\n")
    allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
      "",
      "error",
      ok_exit_status,
    ])

    expect {
      Doodlesack::Build.run
    }.not_to output(
      /error/
    ).to_stdout
  end

  context "the ios app build fails" do
    it "prints the error returned by `expo build:ios`" do
      error_exit_status = 1
      write_app_json(with_version: "1.0.0")
      allow(build_instance).to receive(:exit)
      allow($stdin).to receive(:gets).and_return("patch\n")
      allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
        "",
        "some error",
        error_exit_status,
      ])

      expect {
        Doodlesack::Build.run
      }.to output(
        /some error/
      ).to_stdout
    end

    it "does not modify the version in app.json" do
      error_exit_status = 1
      allow(build_instance).to receive(:print)
      allow(build_instance).to receive(:exit)
      write_app_json(with_version: "1.0.0")
      allow($stdin).to receive(:gets).and_return("patch\n")
      allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
        nil,
        "some error",
        error_exit_status,
      ])

      expect {
        Doodlesack::Build.run
      }.not_to change { File.read("app.json") }
    end

    it "exits the program" do
      error_exit_status = 1
      allow(build_instance).to receive(:print)
      allow(build_instance).to receive(:exit)
      write_app_json(with_version: "1.0.0")
      allow($stdin).to receive(:gets).and_return("patch\n")
      allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
        nil,
        "some error",
        error_exit_status,
      ])

      Doodlesack::Build.run

      expect(build_instance).to have_received(:exit)
    end
  end

  it "downloads the built ios .ipa file" do
    ok_exit_status = 0
    build_link = "https://hello.world"
    write_app_json(with_version: "1.0.0")
    allow($stdin).to receive(:gets).and_return("patch\n")
    allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
      successful_expo_build_output(build_link: build_link),
      "",
      ok_exit_status,
    ])

    fake_path = instance_double(String)
    fake_tempfile = double
    http_double = instance_double(URI::HTTP)
    allow(fake_tempfile).to receive(:path).and_return(fake_path)
    allow(URI).to receive(:parse).with(build_link).and_return(http_double)
    allow(http_double).to receive(:open).and_return(fake_tempfile)
    allow(fake_tempfile).to receive(:close)
    allow(FileUtils).to receive(:mv)

    Doodlesack::Build.run

    expect(fake_tempfile).to have_received(:close)
    expect(FileUtils).to have_received(:mv).with(fake_path, "ios_build.ipa")
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

  def stub_expo_build
    allow(Open3).to receive(:capture3).with("expo build:ios")
      .and_return(["", "", 0])
  end

  def write_app_json(with_version:)
    File.open("app.json", "w+") do |file|
      file.write(app_json_content_with_version(with_version))
    end
  end
end

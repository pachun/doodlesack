require "spec_helper"

describe Doodlesack::Build do
  after(:each) do
    File.delete("app.json")
  end

  it "asks the user which type of update they're building for" do
    write_app_json(with_version: "1.0.0")
    allow($stdin).to receive(:gets).and_return("\n")

    expect {
      Doodlesack::Build.run
    }.to output(
      "Which type of update? [major|minor|patch] (default is patch)"
    ).to_stdout
  end

  context "the user responds to the build type question with 'major'" do
    it "bumps the major version number in app.json" do
      stub_prints
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
      stub_prints
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
      stub_prints
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

  # it "builds the ios app" do
  #   File.open("app.json", "w+") do |file|
  #     file.write(app_json_content_with_version("1.0.0"))
  #   end
  #   allow(Doodlesack::Build).to receive(:print)
  #   allow($stdin).to receive(:gets).and_return("patch\n")
  #   allow(Open3).to receive(:capture3)
  #
  #   Doodlesack::Build.run
  #
  #   expect(Open3).to have_received(:capture3).with("expo build:ios")
  # end

  context "the ios app build fails" do
    # it "prints the error returned by `expo build:ios`" do
    #   File.open("app.json", "w+") do |file|
    #     file.write(app_json_content_with_version("1.0.0"))
    #   end
    #   allow(Doodlesack::Build).to receive(:print)
    #   allow($stdin).to receive(:gets).and_return("patch\n")
    #   standard_output = nil
    #   standard_error = "FAKE ERROR"
    #   exit_status = 1
    #   allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
    #     standard_output,
    #     standard_error,
    #     exit_status,
    #   ])
    #
    #   expect {
    #     Doodlesack::Build.run
    #   }.to output(
    #     "FAKE ERROR\n"
    #   ).to_stdout
    # end

    # it "does not modify the version in app.json" do
    #   File.open("app.json", "w+") do |file|
    #     file.write(app_json_content_with_version("1.0.0"))
    #   end
    #   allow(Doodlesack::Build).to receive(:print)
    #   allow($stdin).to receive(:gets).and_return("patch\n")
    #   standard_output = nil
    #   standard_error = "FAKE ERROR"
    #   exit_status = 1
    #   allow(Open3).to receive(:capture3).with("expo build:ios").and_return([
    #     standard_output,
    #     standard_error,
    #     exit_status,
    #   ])
    #
    #   Doodlesack::Build.run
    #
    #   expect(File.read("app.json")).to eq(app_json_content_with_version("1.0.0"))
    # end
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

  def stub_prints
    build_instance = Doodlesack::Build.new
    allow(build_instance).to receive(:print)
    allow(Doodlesack::Build).to receive(:new).and_return(build_instance)
  end

  def write_app_json(with_version:)
    File.open("app.json", "w+") do |file|
      file.write(app_json_content_with_version(with_version))
    end
  end
end
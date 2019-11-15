require "spec_helper"

describe Doodlesack::Build do
  it "asks the user which type of update they're building for" do
    File.open("app.json", "w+") do |file|
      file.write(app_json_content_with_version("1.0.0"))
    end

    allow($stdin).to receive(:gets).and_return("\n")

    expect {
      Doodlesack::Build.run
    }.to(
      output("Which type of update? [major|minor|patch] (default is patch)")
        .to_stdout
    )

    File.delete("app.json")
  end

  context "the user responds to the build type question with 'major'" do
    it "bumps the major version number in app.json" do
      File.open("app.json", "w+") do |file|
        file.write(app_json_content_with_version("1.0.0"))
      end

      allow(Doodlesack::Build).to receive(:print)
      allow($stdin).to receive(:gets).and_return("major\n")

      Doodlesack::Build.run

      expect(File.read("app.json")).to eq(
        app_json_content_with_version("2.0.0")
      )

      File.delete("app.json")
    end
  end

  context "the user responds to the build type question with 'minor'" do
    it "bumps the minor version number in app.json" do
      File.open("app.json", "w+") do |file|
        file.write(app_json_content_with_version("1.0.0"))
      end

      allow(Doodlesack::Build).to receive(:print)
      allow($stdin).to receive(:gets).and_return("minor\n")

      Doodlesack::Build.run

      expect(File.read("app.json")).to eq(
        app_json_content_with_version("1.1.0")
      )

      File.delete("app.json")
    end
  end

  context "the user responds to the build type question with 'patch'" do
    it "bumps the patch version number in app.json" do
      File.open("app.json", "w+") do |file|
        file.write(app_json_content_with_version("1.0.0"))
      end

      allow(Doodlesack::Build).to receive(:print)
      allow($stdin).to receive(:gets).and_return("patch\n")

      Doodlesack::Build.run

      expect(File.read("app.json")).to eq(
        app_json_content_with_version("1.0.1")
      )

      File.delete("app.json")
    end
  end
  #
  # it "builds the ios app" do
  #   allow(Open3).to receive(:capture3)
  # end

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
end

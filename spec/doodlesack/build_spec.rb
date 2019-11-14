require "spec_helper"

describe Doodlesack::Build do
  it "asks the user which type of update they're building for" do
    File.open("app.json", "w+") do |file|
      file.write(app_json_content_with_version("1.0.0"))
    end

    expect {
      Doodlesack::Build.run
    }.to(
      output("Which type of update? [major|minor|patch] (default is patch)")
        .to_stdout
    )
  end

  context "the user responds to the build type question with 'major'" do
    it "bumps the major version number in app.json" do
      File.open("app.json", "w+") do |file|
        file.write(app_json_content_with_version("1.0.0"))
      end

      allow($stdin).to receive(:gets).and_return("major")

      Doodlesack::Build.run

      expect(File.read("app.json")).to eq(
        app_json_content_with_version("2.0.0")
      )

      File.delete("app.json")
    end
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
end

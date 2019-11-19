require "spec_helper"

describe Doodlesack::Build do
  let(:build_instance) { Doodlesack::Build.new }

  before(:each) do
    allow(Doodlesack::Build).to receive(:new).and_return(build_instance)
    allow(build_instance).to receive(:system)

    write_app_json(with_version: "1.0.0")
  end

  after(:each) do
    File.delete("app.json")
  end

  def stub_prints
    allow(build_instance).to receive(:print)
  end

  it "asks the user which type of update they're building for" do
    stub_expo_build(:success)
    stub_build_download
    allow($stdin).to receive(:gets).and_return("\n")

    expect {
      Doodlesack::Build.run
    }.to output(
      /Which type of update\? \[major\|minor\|patch\] \(default is patch\)/
    ).to_stdout
  end

  context "the user responds to the build type question with 'major'" do
    it "bumps the major version number in app.json" do
      stub_prints
      allow(build_instance).to receive(:download_build)
      stub_expo_build(:success)
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
      allow(build_instance).to receive(:download_build)
      stub_expo_build(:success)
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
      allow(build_instance).to receive(:download_build)
      stub_expo_build(:success)
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
    allow(build_instance).to receive(:download_build)
    stub_prints
    allow($stdin).to receive(:gets).and_return("patch\n")
    stub_expo_build(:success)

    Doodlesack::Build.run

    expect(Open3).to have_received(:capture3).with("expo build:ios")
  end

  it "does not print an error" do
    allow(build_instance).to receive(:download_build)
    allow($stdin).to receive(:gets).and_return("patch\n")
    stub_expo_build(:success, error: "error")

    expect {
      Doodlesack::Build.run
    }.not_to output(
      /error/
    ).to_stdout
  end

  context "the ios app build fails" do
    it "prints the error returned by `expo build:ios`" do
      stub_expo_build(:error, error: "some error")
      allow($stdin).to receive(:gets).and_return("patch\n")

      expect {
        Doodlesack::Build.run
      }.to output(
        /some error/
      ).to_stdout
    end

    it "does not modify the version in app.json" do
      stub_expo_build(:error)
      stub_prints
      allow($stdin).to receive(:gets).and_return("patch\n")

      expect {
        Doodlesack::Build.run
      }.not_to change { File.read("app.json") }
    end

    it "does not download anything" do
      stub_expo_build(:error)
      allow(build_instance).to receive(:download_build)
      stub_prints
      allow($stdin).to receive(:gets).and_return("patch\n")

      Doodlesack::Build.run

      expect(build_instance).not_to have_received(:download_build)
    end
  end

  context "the build succeeds and is located at https://hello.world" do
    it "downloads the built ios .ipa file" do
      build_link = "https://hello.world"
      stub_expo_build(:success, build_link: build_link)
      stub_prints
      allow($stdin).to receive(:gets).and_return("patch\n")

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
  end

  context "the build succeeds and is located at http://what.is.jeopardy" do
    it "downloads the built ios .ipa file" do
      stub_prints
      allow($stdin).to receive(:gets).and_return("patch\n")

      build_link = "http://what.is.jeopardy"
      stub_expo_build(:success, build_link: build_link)
      stubbed_download = stub_build_download(build_link)

      Doodlesack::Build.run

      expect(stubbed_download).to have_been_downloaded
    end
  end

  it "uploads the built ios .ipa file to app store connect" do
    stub_prints
    allow($stdin).to receive(:gets).and_return("patch\n")

    build_link = "https://hello.world"
    stub_expo_build(:success, build_link: build_link)
    allow(build_instance).to receive(:system)

    Doodlesack::Build.run

    expect(build_instance).to have_received(:system).with(
      "xcrun altool --upload-app -f ios_build.ipa -u nick@pachulski.me -p yxuz-itgt-qulp-qjgt"
    )
  end

  it "deletes the downloaded iOS .ipa standalone build file" do
    build_link = "https://hello.world"
    stub_expo_build(:success, build_link: build_link)
    stub_prints
    allow(build_instance).to receive(:system)
    allow($stdin).to receive(:gets).and_return("patch\n")

    Doodlesack::Build.run

    expect(build_instance).to have_received(:system).with("rm ios_build.ipa")
  end
end

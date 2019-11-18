require "open3"
require "open-uri"

class Doodlesack::Build
  def self.run
    new.run
  end

  def run
    bump_version
    build
    if build_succeeded?
      download_build
      upload_build_to_appstore_connect
      delete_downloaded_build
    else
      unbump_version
      print "#{build_error}\n"
    end
  end

  private

  attr_reader :type_of_update, :build_output, :build_error, :build_command_status

  def unbump_version
    update_version(original_version)
  end

  def build_succeeded?
    build_command_status == 0
  end

  def build
    @build_output, @build_error, @build_command_status = \
      Open3.capture3("expo build:ios")
  end

  def bump_version
    ask_for_type_of_update
    update_version(bumped_version)
  end

  def download_build
    tempfile = URI.parse(build_link_url).open
    tempfile.close
    FileUtils.mv(tempfile.path, "ios_build.ipa")
  end

  def build_link_url
    build_link_from(build_output)
  end

  def ask_for_type_of_update
    print "Which type of update? [major|minor|patch] (default is patch)"
    @type_of_update = STDIN.gets.chomp.to_sym
  end

  def original_app_json
    @original_content ||= JSON.parse(File.read("app.json"))
  end

  def original_version
    @original_version ||= original_app_json["expo"]["version"]
  end

  def bumped_version
    Doodlesack::SemanticVersion.bump(original_version, type_of_update)
  end

  def update_version(version)
    updated_json = original_app_json
    updated_json["expo"]["version"] = version
    File.open("app.json", "w+") do |file|
      file.write(JSON.pretty_generate(updated_json) + "\n")
    end
  end

  def build_link_from(build_output)
    build_output&.split("\n")&.detect do |line|
      line.start_with?("Successfully built standalone app: ")
    end&.split(": ")&.last
  end

  def upload_build_to_appstore_connect
    system "xcrun altool --upload-app -f ios_build.ipa -u nick@pachulski.me -p yxuz-itgt-qulp-qjgt"
  end

  def delete_downloaded_build
    system "rm ios_build.ipa"
  end
end

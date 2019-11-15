require "open3"
require "open-uri"

class Doodlesack::Build
  def self.run
    new.run
  end

  def run
    ask_for_type_of_update

    _, error, status = Open3.capture3("expo build:ios")
    if status != 0
      print "#{error}\n"
      exit
      return
    end

    bump_version

    tempfile = URI.parse("https://hello.world").open
    tempfile.close
    FileUtils.mv(tempfile.path, "ios_build.ipa")
  end

  private

  attr_reader :type_of_update

  def ask_for_type_of_update
    print "Which type of update? [major|minor|patch] (default is patch)"
    @type_of_update = STDIN.gets.chomp.to_sym
  end

  def bump_version
    json = JSON.parse(File.read("app.json"))
    version = json["expo"]["version"]
    bumped_version = Doodlesack::SemanticVersion.bump(
      version,
      type_of_update,
    )
    json["expo"]["version"] = bumped_version
    File.open("app.json", "w+") do |file|
      file.write(JSON.pretty_generate(json) + "\n")
    end
  end
end

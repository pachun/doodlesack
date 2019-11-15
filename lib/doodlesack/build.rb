class Doodlesack::Build
  def self.run
    print "Which type of update? [major|minor|patch] (default is patch)"
    version_bump_type = STDIN.gets.chomp
    json = JSON.parse(File.read("app.json"))
    version = json["expo"]["version"]
    bumped_version = Doodlesack::SemanticVersion.bump(
      version,
      version_bump_type.to_sym,
    )
    json["expo"]["version"] = bumped_version
    File.open("app.json", "w+") do |file|
      file.write(JSON.pretty_generate(json) + "\n")
    end

# stdout, stderr, status = Open3.capture3("expo build:ios")
  end
end

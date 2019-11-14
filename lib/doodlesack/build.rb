class Doodlesack::Build
  def self.run
    print "Which type of update? [major|minor|patch] (default is patch)"
    json = JSON.parse(File.read("app.json"))
    version = json["expo"]["version"]
    bumped_version = Doodlesack::SemanticVersion.bump(version, :major)
    json["expo"]["version"] = bumped_version
    File.open("app.json", "w+") do |file|
      file.write(JSON.pretty_generate(json) + "\n")
    end
  end
end

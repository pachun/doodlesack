class Doodlesack
  class SemanticVersion
    def self.bump(version, type)
      new(version, type).bump
    end

    def initialize(version, type)
      @version = version
      @type = type
    end

    def bump
      if type == :patch
        patch_version_bump
      elsif type == :minor
        minor_version_bump
      elsif type == :major
        major_version_bump
      end
    end

    private

    attr_reader :version, :type

    def patch_version_bump
      "#{major_version}.#{minor_version}.#{patch_version + 1}"
    end

    def minor_version_bump
      "#{major_version}.#{minor_version + 1}.#{patch_version}"
    end

    def major_version_bump
      "#{major_version + 1}.#{minor_version}.#{patch_version}"
    end

    def major_version
      version.split(".").first.to_i
    end

    def minor_version
      version.split(".")[1].to_i
    end

    def patch_version
      version.split(".").last.to_i
    end
  end
end

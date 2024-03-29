class Doodlesack
  class Deploy
    def self.run
      new.run
    end

    def initialize
      unless File.exist?(Doodlesack::VERSION_NUMBER_FILE)
        create_version_number_file
      end
    end

    def run
      increment_version_number
      if system("expo publish")
        git_commit_version_number_file
        git_tag_over_the_air_deploy
      else
        undo_version_number_change
      end
    end

    private

    def version_number
      @version_number ||= File
        .read(Doodlesack::VERSION_NUMBER_FILE)
        .split
        .detect { |word| /\A\d+\z/ === word }.to_i
    end

    def incremented_version_number
      @incremented_version_number = version_number + 1
    end

    def increment_version_number
      set_version_number(incremented_version_number)
    end

    def undo_version_number_change
      set_version_number(version_number)
    end

    def git_commit_version_number_file
      Doodlesack::Git.add(Doodlesack::VERSION_NUMBER_FILE)
      Doodlesack::Git.commit("Increment version number for over the air deploy")
    end

    def git_tag_over_the_air_deploy
      Doodlesack::Git.delete_tag("over-the-air-deployed")
      Doodlesack::Git.tag("over-the-air-deployed")
    end

    def create_version_number_file
      set_version_number(0)
    end

    def set_version_number(version_number)
      create_new_or_overwrite_existing = "w+"
      version_number_file = File.open(
        Doodlesack::VERSION_NUMBER_FILE,
        create_new_or_overwrite_existing,
      )
      version_number_file.write <<~END_OF_STRING
        const OverTheAirVersionNumber = #{version_number}

        export default OverTheAirVersionNumber
      END_OF_STRING
      version_number_file.close
    end
  end
end

class Doodlesack
  class Deploy
    VERSION_NUMBER_FILE = "OverTheAirVersion.ts"

    def self.run
      new.run
    end

    def initialize
      unless File.exist?(VERSION_NUMBER_FILE)
        create_version_number_file
      end
    end

    def run
      increment_version_number
      undo_version_number_change unless system("expo publish")
      `git add #{VERSION_NUMBER_FILE}`
      `git commit -m 'Increment version number for over the air deploy'`
    end

    private

    def version_number
      @version_number ||= File
        .read(VERSION_NUMBER_FILE)
        .split
        .detect { |word| /\A\d+\z/ === word }.to_i
    end

    def incremented_version_number
      @incremented_version_number = version_number + 1
    end

    def increment_version_number
      update_version_number(incremented_version_number)
    end

    def undo_version_number_change
      update_version_number(version_number)
    end

    def create_version_number_file
      create_new_or_overwrite_existing = "w+"
      version_number_file = File.open(
        VERSION_NUMBER_FILE,
        create_new_or_overwrite_existing,
      )
      version_number_file.write <<~END_OF_STRING
        const OverTheAirVersionNumber = 0

        export default OverTheAirVersionNumber
      END_OF_STRING
      version_number_file.close
    end

    def update_version_number(version_number)
      create_new_or_overwrite_existing = "w+"
      version_number_file = File.open(
        VERSION_NUMBER_FILE,
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

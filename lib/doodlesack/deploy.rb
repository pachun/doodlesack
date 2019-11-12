class Doodlesack
  class Deploy
    VERSION_NUMBER_FILE = "./OverTheAirVersion.ts"

    def self.run
      new.run
    end

    def initialize
      @version_number = File
        .read(VERSION_NUMBER_FILE)
        .split
        .detect { |word| /\A\d+\z/ === word }.to_i
      @incremented_version_number = @version_number + 1
    end

    def run
      update_version_number(incremented_version_number)

      if !system("expo publish")
        update_version_number(version_number)
      end
    end

    private

    attr_reader :version_number, :incremented_version_number

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

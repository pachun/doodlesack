class Doodlesack
  class Deploy
    OVER_THE_AIR_VERSION_FILE_PATH = "./OverTheAirVersion.ts"

    def self.run
      new.run
    end

    def run
      incremented_over_the_air_version_number = \
        current_over_the_air_version_number + 1
      write_version(incremented_over_the_air_version_number)
    end

    def current_over_the_air_version_number
      File.read(OVER_THE_AIR_VERSION_FILE_PATH)
        .split
        .detect { |word| /\A\d+\z/ === word }.to_i
    end

    def write_version(version)
      create_new_or_overwrite_existing = "w+"
      over_the_air_version_file = File.open(
        OVER_THE_AIR_VERSION_FILE_PATH,
        create_new_or_overwrite_existing,
      )
      over_the_air_version_file.write <<~END_OF_STRING
        const OverTheAirVersionNumber = #{version}

        export default OverTheAirVersionNumber
      END_OF_STRING
      over_the_air_version_file.close
    end
  end
end

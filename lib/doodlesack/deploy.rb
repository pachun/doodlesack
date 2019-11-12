class Doodlesack
  class Deploy
    OVER_THE_AIR_VERSION_FILE_PATH = "OverTheAirVersion.ts"

    def self.run
      new.run
    end

    def run
      current_over_the_air_version = File
        .read(OVER_THE_AIR_VERSION_FILE_PATH)
        .split
        .detect { |word| /\A\d+\z/ === word }

      incremented_over_the_air_version = current_over_the_air_version.to_i + 1

      create_new_or_overwrite_existing = "w+"
      over_the_air_version_file = File.open(
        OVER_THE_AIR_VERSION_FILE_PATH,
        create_new_or_overwrite_existing,
      )
      over_the_air_version_file.write <<~END_OF_STRING
        const OverTheAirVersionNumber = #{incremented_over_the_air_version}

        export default OverTheAirVersionNumber
      END_OF_STRING
      over_the_air_version_file.close
    end
  end
end

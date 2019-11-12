require "spec_helper"

describe Doodlesack::Deploy do
  OVER_THE_AIR_VERSION_FILE_PATH = "OverTheAirVersion.ts"

  describe "self#run" do
    it "increments the over-the-air version number from 0 to 1" do
      create_new_or_overwrite_existing = "w+"
      over_the_air_version_file = File.open(
        OVER_THE_AIR_VERSION_FILE_PATH,
        create_new_or_overwrite_existing,
      )
      over_the_air_version_file.write <<~END_OF_STRING
        const OverTheAirVersionNumber = 0

        export default OverTheAirVersionNumber
      END_OF_STRING
      over_the_air_version_file.close

      Doodlesack::Deploy.run

      read_only = "r"
      over_the_air_version_file = File.open(
        OVER_THE_AIR_VERSION_FILE_PATH,
        read_only,
      )
      updated_over_the_air_version_file_content = over_the_air_version_file.read

      expect(updated_over_the_air_version_file_content).to eq <<~END_OF_STRING
        const OverTheAirVersionNumber = 1

        export default OverTheAirVersionNumber
      END_OF_STRING
    end

    it "increments the over-the-air version number from 1 to 2" do
      create_new_or_overwrite_existing = "w+"
      over_the_air_version_file = File.open(
        OVER_THE_AIR_VERSION_FILE_PATH,
        create_new_or_overwrite_existing,
      )
      over_the_air_version_file.write <<~END_OF_STRING
        const OverTheAirVersionNumber = 1

        export default OverTheAirVersionNumber
      END_OF_STRING
      over_the_air_version_file.close

      Doodlesack::Deploy.run

      read_only = "r"
      over_the_air_version_file = File.open(
        OVER_THE_AIR_VERSION_FILE_PATH,
        read_only,
      )
      updated_over_the_air_version_file_content = over_the_air_version_file.read

      expect(updated_over_the_air_version_file_content).to eq <<~END_OF_STRING
        const OverTheAirVersionNumber = 2

        export default OverTheAirVersionNumber
      END_OF_STRING
    end
  end
end

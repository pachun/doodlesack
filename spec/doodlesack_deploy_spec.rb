require "spec_helper"

describe Doodlesack::Deploy do
  VERSION_NUMBER_FILE = "OverTheAirVersion.ts"

  describe "self#run" do
    it "increments the over-the-air version number from 0 to 1" do
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

      Doodlesack::Deploy.run

      updated_version_number_file_content = \
        File.read(VERSION_NUMBER_FILE)

      expect(updated_version_number_file_content).to eq <<~END_OF_STRING
        const OverTheAirVersionNumber = 1

        export default OverTheAirVersionNumber
      END_OF_STRING
    end

    it "increments the over-the-air version number from 1 to 2" do
      create_new_or_overwrite_existing = "w+"
      version_number_file = File.open(
        VERSION_NUMBER_FILE,
        create_new_or_overwrite_existing,
      )
      version_number_file.write <<~END_OF_STRING
        const OverTheAirVersionNumber = 1

        export default OverTheAirVersionNumber
      END_OF_STRING
      version_number_file.close

      Doodlesack::Deploy.run

      updated_version_number_file_content = \
        File.read(VERSION_NUMBER_FILE)

      expect(updated_version_number_file_content).to eq <<~END_OF_STRING
        const OverTheAirVersionNumber = 2

        export default OverTheAirVersionNumber
      END_OF_STRING
    end
  end
end

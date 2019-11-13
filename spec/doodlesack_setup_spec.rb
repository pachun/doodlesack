require "spec_helper"

describe Doodlesack::Setup do
  describe "self#run" do
    it "creates the version number file for version: 0" do
      Doodlesack::Setup.run

      expect(File.exist?(Doodlesack::VERSION_NUMBER_FILE)).to be(true)

      updated_version_number_file_content = \
        File.read(Doodlesack::VERSION_NUMBER_FILE)

      expect(updated_version_number_file_content).to eq <<~END_OF_STRING
        const OverTheAirVersionNumber = 0

        export default OverTheAirVersionNumber
      END_OF_STRING

      File.delete(Doodlesack::VERSION_NUMBER_FILE)
    end
  end
end

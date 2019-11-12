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

      stub_successful_expo_publish

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

      stub_successful_expo_publish

      Doodlesack::Deploy.run

      updated_version_number_file_content = \
        File.read(VERSION_NUMBER_FILE)

      expect(updated_version_number_file_content).to eq <<~END_OF_STRING
        const OverTheAirVersionNumber = 2

        export default OverTheAirVersionNumber
      END_OF_STRING
    end

    it "deploys the build to expo" do
      deploy_instance = Doodlesack::Deploy.new
      allow(Doodlesack::Deploy).to receive(:new).and_return(deploy_instance)
      allow(deploy_instance).to receive(:system)

      Doodlesack::Deploy.run

      expect(deploy_instance).to have_received(:system).with("expo publish")
    end

    context "the expo deploy fails" do
      it "does not change the over-the-air version number" do
        create_new_or_overwrite_existing = "w+"
        version_number_file = File.open(
          VERSION_NUMBER_FILE,
          create_new_or_overwrite_existing,
        )
        version_number_file.write <<~END_OF_STRING
          const OverTheAirVersionNumber = 2

          export default OverTheAirVersionNumber
        END_OF_STRING
        version_number_file.close

        deploy_instance = Doodlesack::Deploy.new
        allow(Doodlesack::Deploy).to receive(:new).and_return(deploy_instance)
        allow(deploy_instance).to receive(:system).with("expo publish")
          .and_return(false)

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

  def stub_successful_expo_publish
    deploy_instance = Doodlesack::Deploy.new
    allow(Doodlesack::Deploy).to receive(:new).and_return(deploy_instance)
    allow(deploy_instance).to receive(:system).with("expo publish").and_return(true)
  end
end

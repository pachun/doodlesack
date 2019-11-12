require "spec_helper"

describe Doodlesack::Deploy do
  VERSION_NUMBER_FILE = "OverTheAirVersion.ts"

  describe "self#run" do
    after(:each) do
      File.delete(VERSION_NUMBER_FILE)
    end

    context "the version number file does not exist" do
      it "creates the version number file for version: 1" do
        stub_successful_expo_publish

        Doodlesack::Deploy.run

        updated_version_number_file_content = \
          File.read(VERSION_NUMBER_FILE)

        expect(updated_version_number_file_content).to eq <<~END_OF_STRING
          const OverTheAirVersionNumber = 1

          export default OverTheAirVersionNumber
        END_OF_STRING
      end
    end

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
      allow(deploy_instance).to receive(:`)

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
      allow(deploy_instance).to receive(:`)

        Doodlesack::Deploy.run

        updated_version_number_file_content = \
          File.read(VERSION_NUMBER_FILE)

        expect(updated_version_number_file_content).to eq <<~END_OF_STRING
          const OverTheAirVersionNumber = 2

          export default OverTheAirVersionNumber
        END_OF_STRING
      end
    end

    it "commits the version number increment to git" do
      deploy_instance = Doodlesack::Deploy.new
      allow(Doodlesack::Deploy).to receive(:new).and_return(deploy_instance)
      allow(deploy_instance).to receive(:system).with("expo publish")
        .and_return(true)
      allow(deploy_instance).to receive(:`)

      Doodlesack::Deploy.run

      expect(deploy_instance).to have_received(:`)
        .with("git add #{VERSION_NUMBER_FILE}")
      expect(deploy_instance).to have_received(:`)
        .with("git commit -m 'Increment version number for over the air deploy'")
    end

    # it "deletes the any older over-the-air-deployed git tags" do
    #   deploy_instance = Doodlesack::Deploy.new
    #   allow(Doodlesack::Deploy).to receive(:new).and_return(deploy_instance)
    #   allow(deploy_instance).to receive(:system).with("expo publish")
    #     .and_return(true)
    #   allow(deploy_instance).to receive(:`)
    #
    #   Doodlesack::Deploy.run
    #
    #   expect(deploy_instance).to have_received(:`)
    #     .with("git tag -d over-the-air-deployed")
    #   expect(deploy_instance).to have_received(:`)
    #     .with("git push origin --delete over-the-air-deployed")
    # end
  end

  def stub_successful_expo_publish
    deploy_instance = Doodlesack::Deploy.new
    allow(Doodlesack::Deploy).to receive(:new).and_return(deploy_instance)
    allow(deploy_instance).to receive(:system).with("expo publish").and_return(true)
    allow(deploy_instance).to receive(:`)
  end
end

class Doodlesack::Setup
  def self.run
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
end

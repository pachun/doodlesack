require "spec_helper"

describe Doodlesack::SemanticVersion do
  describe "self#bump(version, type)" do
    context "type is :patch" do
      it "returns 0.0.1 given version 0.0.0" do
        expect(Doodlesack::SemanticVersion.bump("0.0.0", :patch)).to eq("0.0.1")
      end

      it "returns 1.1.2 given version 1.1.1" do
        expect(Doodlesack::SemanticVersion.bump("1.1.1", :patch)).to eq("1.1.2")
      end
    end

    context "type is :minor" do
      it "returns 0.1.0 given version 0.0.0" do
        expect(Doodlesack::SemanticVersion.bump("0.0.0", :minor)).to eq("0.1.0")
      end

      it "returns 1.2.1 given version 1.1.1" do
        expect(Doodlesack::SemanticVersion.bump("1.1.1", :minor)).to eq("1.2.1")
      end
    end

    context "type is :major" do
      it "returns 1.0.0 given version 0.0.0" do
        expect(Doodlesack::SemanticVersion.bump("0.0.0", :major)).to eq("1.0.0")
      end

      it "returns 2.1.1 given version 1.1.1" do
        expect(Doodlesack::SemanticVersion.bump("1.1.1", :major)).to eq("2.1.1")
      end
    end
  end
end

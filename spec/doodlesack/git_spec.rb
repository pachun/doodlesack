require "spec_helper"

describe Doodlesack::Git do
  describe "self#add(file_name)" do
    it "stages file_name" do
      allow(Doodlesack::Git).to receive(:`)

      Doodlesack::Git.add("hello")

      expect(Doodlesack::Git).to have_received(:`).with("git add hello")

      Doodlesack::Git.add("world")

      expect(Doodlesack::Git).to have_received(:`).with("git add world")
    end
  end

  describe "self#commit(message)" do
    it "commits the staged changes with the provided message" do
      allow(Doodlesack::Git).to receive(:`)

      Doodlesack::Git.commit("hello")

      expect(Doodlesack::Git).to have_received(:`).with("git commit -m 'hello'")

      Doodlesack::Git.commit("world")

      expect(Doodlesack::Git).to have_received(:`).with("git commit -m 'world'")
    end
  end

  describe "self#delete_tag(tag_name)" do
    it "deletes the tag named tag_name" do
      allow(Doodlesack::Git).to receive(:`)

      Doodlesack::Git.delete_tag("hello")

      expect(Doodlesack::Git).to have_received(:`).with("git tag -d hello")

      Doodlesack::Git.delete_tag("world")

      expect(Doodlesack::Git).to have_received(:`).with("git tag -d world")
    end
  end

  describe "self#tag(tag_name)" do
    it "creates a tag named tag_name" do
      allow(Doodlesack::Git).to receive(:`)

      Doodlesack::Git.tag("hello")

      expect(Doodlesack::Git).to have_received(:`)
        .with("git tag -a hello -m 'hello'")

      Doodlesack::Git.tag("world")

      expect(Doodlesack::Git).to have_received(:`)
        .with("git tag -a world -m 'world'")
    end
  end
end

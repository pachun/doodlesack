class Doodlesack
  module Git
    def self.add(file)
      `git add #{file}`
    end

    def self.commit(message)
      `git commit -m '#{message}'`
    end

    def self.delete_tag(tag_name)
      `git tag -d #{tag_name}`
    end

    def self.tag(tag_name)
      `git tag -a #{tag_name} -m '#{tag_name}'`
    end
  end
end

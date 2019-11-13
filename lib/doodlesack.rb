require "doodlesack/deploy"
require "doodlesack/setup"

class Doodlesack
  def self.run(command_line_arguments)
    new(command_line_arguments).run
  end

  attr_reader :command_line_arguments

  def initialize(command_line_arguments)
    @command_line_arguments = command_line_arguments
  end

  def run
    if command_line_arguments.empty?
      print_usage_description
    elsif !in_an_expo_project_directory?
      print_expo_instructions
    elsif command_line_arguments.first == "setup"
      Doodlesack::Setup.run
    elsif !git_status_is_clean?
      print_git_instructions
    elsif command_line_arguments.first == "deploy"
      Doodlesack::Deploy.run
    end
  end

  private

  def in_an_expo_project_directory?
    File.file?("app.json")
  end

  def git_status_is_clean?
    `git status`.split("\n").last == "nothing to commit, working tree clean"
  end

  def print_usage_description
    puts "USAGE: doodlesack [setup|deploy]"
  end

  def print_expo_instructions
    puts "No app.json file present. Are you in an Expo project directory?"
  end

  def print_git_instructions
    puts "Nothing was deployed because you need to commit your changes to git first."
  end
end

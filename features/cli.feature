Feature: doodlesack
  Running the doodlesack command line executable
  Prints a usage description

  Scenario: Running without arguments
    When I run `doodlesack`
    Then the output should contain "USAGE: doodlesack [init|deploy]"

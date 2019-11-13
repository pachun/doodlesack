require 'simplecov'

if ENV["COVERAGE"]
  SimpleCov.minimum_coverage 100
  SimpleCov.start
end

VERSION_NUMBER_FILE = "OverTheAirVersion.ts"

require "doodlesack"

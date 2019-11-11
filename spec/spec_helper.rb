require 'simplecov'

if ENV["COVERAGE"]
  SimpleCov.minimum_coverage 100
  SimpleCov.start
end

require "doodlesack"

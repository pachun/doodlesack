Gem::Specification.new do |s|
  s.name         = "doodlesack"
  s.version      = "0.0.0"
  s.summary      = "Easier Expo builds and deploys"
  s.description  = "Save time building and deploying your Expo React Native app."
  s.authors      = ["Nick Pachulski"]
  s.email        = "nick@pachulski.me"
  s.files        = ["lib/doodlesack.rb"]
  s.homepage     = "https://github.com/pachun/doodlesack"
  s.license      = "MIT"
  s.executables << "doodlesack"

  s.add_development_dependency "rspec", "~> 3.9.0"
  s.add_development_dependency "simplecov", "~> 0.17.1"
  s.add_development_dependency "cucumber", "~> 3.1.2"
  s.add_development_dependency "aruba", "~> 0.14.1"
end

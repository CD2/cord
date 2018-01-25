$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cord_v2/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cord_v2"
  s.version     = CordV2::VERSION
  s.authors     = ["James Page"]
  s.email       = ["james.page@cd2solutions.co.uk"]
  s.summary     = "Summary of CordV2."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.2"

  s.add_development_dependency "sqlite3"
end
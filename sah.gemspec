# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sah/version'

Gem::Specification.new do |spec|
  spec.name          = "sah"
  spec.version       = Sah::VERSION
  spec.authors       = ["f440"]
  spec.email         = ["freq440@gmail.com"]

  spec.summary       = "Command line util for atlassian stash"
  spec.description   = "Sah is command line util for Atlassian Stash."
  spec.homepage      = "https://github.com/f440/sah"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "git", "~> 1.2.9.1"
  spec.add_dependency "faraday", "~> 0.9.1"
  spec.add_dependency "faraday_middleware", "~> 0.10.0"
  spec.add_dependency "hirb", "~> 0.7.3"
  spec.add_dependency "hirb-unicode", "~> 0.0.5"
  spec.add_dependency "launchy", "~> 2.4.3"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end

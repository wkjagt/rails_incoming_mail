# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_incoming_mail/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_incoming_mail"
  spec.version       = RailsIncomingMail::VERSION
  spec.authors       = ["Willem van der Jagt"]
  spec.email         = ["wkjagt@gmail.com"]
  spec.summary       = %q{Enables your rails app to receive email.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'gserver'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", '~> 5.5.1'
  spec.add_development_dependency "mocha", '~> 1.1.0'
end

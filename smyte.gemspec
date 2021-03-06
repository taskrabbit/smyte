# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smyte/version'

Gem::Specification.new do |spec|
  spec.name          = "smyte"
  spec.version       = Smyte::VERSION
  spec.authors       = ["Brian Leonard"]
  spec.email         = ["brian@bleonard.com"]

  spec.summary       = %q{Talk to Smyte service}
  spec.description   = %q{Smyte does fraud detection}
  spec.homepage      = "https://www.taskrabbit.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "byebug", "~> 3.5.1"
  spec.add_development_dependency "vcr", "~> 3.0.1"
  spec.add_development_dependency "webmock", "~> 1.24.3"
end

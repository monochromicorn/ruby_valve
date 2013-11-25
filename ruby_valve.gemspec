# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_valve/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby_valve"
  spec.version       = RubyValve::VERSION
  spec.authors       = ["monochromicorn"]
  spec.email         = ["necrocommit@gmail.com"]
  spec.description   = %q{This gem provide a mechanism for doing easy flow type code pattern}
  spec.summary       = %q{Programming execution flow control}
  spec.homepage      = "http://github.com/monochromicorn/ruby_valve#step_n-methods"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry-debugger"
end

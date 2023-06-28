# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'music-theory/version'

Gem::Specification.new do |spec|
  spec.name          = "music-theory"
  spec.version       = MusicTheory::VERSION
  spec.authors       = ["Carter Thaxton"]
  spec.email         = ["carter.thaxton@gmail.com"]
  spec.summary       = %q{Work with music theory concepts in ruby}
  spec.description   = %q{Handles notes, intervals, scales, chords, in a complete manner.}
  spec.homepage      = "https://github.com/carter-thaxton/music-theory"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.0.0"
  spec.add_development_dependency "rake", ">= 10.0"
end

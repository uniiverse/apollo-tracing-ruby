# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/tracing/version'

Gem::Specification.new do |spec|
  spec.name          = "graphql-tracing"
  spec.version       = Graphql::Tracing::VERSION
  spec.authors       = ["Reginald Suh", "Evgeny Li"]
  spec.email         = ["evgeny.li@universe.com", "rsuh@edu.uwaterloo.ca"]

  spec.summary       = %q{Ruby implementation of GraphQL trace data in the Apollo Tracing format.}
  spec.description   = %q{Ruby implementation of GraphQL trace data in the Apollo Tracing format.}
  spec.homepage      = "https://github.com/uniiverse/graphql-tracing"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0' # keyword args

  spec.add_runtime_dependency "graphql", ">= 1.6.0", "< 2"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end

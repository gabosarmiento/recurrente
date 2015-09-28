# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'recurrente/version'

Gem::Specification.new do |spec|
  spec.name          = "recurrente"
  spec.version       = Recurrente::VERSION
  spec.authors       = ["gabosarmiento"]
  spec.email         = ["gabrielsarmiento@gmail.com"]

  spec.summary       = %q{Un wrapper para el API de pagos recurrentes de Payulatam}
  spec.description   = %q{Una Gem de Ruby para consumir la API de payulatam.com api y manejar los pagos recurrentes}
  spec.homepage      = "https://github.com/gabosarmiento/recurrente.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  # Dependency
  spec.add_dependency "httparty"
  spec.add_dependency "json"
end

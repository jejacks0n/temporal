# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'temporal/version'

Gem::Specification.new do |s|
  s.name        = 'temporal-rails'
  s.version     = Temporal::VERSION
  s.authors     = ['Jeremy Jackson']
  s.email       = ['jejacks0n@gmail.com']
  s.homepage    = 'http://github.com/jejacks0n/temporal'
  s.summary     = 'Temporal: Javascript timezone detection for Rails'
  s.description = 'Javascript timezone detection that also sets Time.zone for Rails to use'
  s.licenses    = ['MIT']

  s.files       = Dir["{lib,vendor}/**/*"] + ["MIT.LICENSE", "README.md"]
  s.test_files  = Dir["{spec}/**/*"]

  # Runtime Dependencies
  s.add_dependency 'railties', ['>= 3.2.5','< 5']
  s.add_dependency 'coffee-rails'

end

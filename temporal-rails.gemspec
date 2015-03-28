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

  # Runtime Dependencies
  # s.add_dependency 'railties', ['>= 3.2.5','< 5'] # no need
  s.add_dependency 'coffee-rails'




  # Development Dependencies
  s.test_files  = Dir["{spec}/**/*"]
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "uglifier"
  s.add_development_dependency "teabag"
  # required for travis-ci and linux environments
  s.add_development_dependency "phantomjs-linux" if RUBY_PLATFORM =~ /linux/

end

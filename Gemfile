source 'http://rubygems.org'

gemspec

# used by the dummy application
gem 'rails', '>= 3.2.8'

group :development, :test do
  gem 'rspec-rails'
  gem 'uglifier'
  gem 'teabag'

  # required for travis-ci and linux environments
  gem "phantomjs-linux" if RUBY_PLATFORM =~ /linux/
end

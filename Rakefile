#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end


# Dummy App
# -----------------------------------------------------------------------------
APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
Bundler::GemHelper.install_tasks


# RSpec
# -----------------------------------------------------------------------------
task 'db:test:prepare' => 'app:db:test:prepare'
load 'rspec/rails/tasks/rspec.rake'

namespace :spec do

  [:engine].each do |sub|
    desc "Run the code examples in spec/#{sub}"
    RSpec::Core::RakeTask.new(sub => 'db:test:prepare') do |t|
      t.pattern = "./spec/#{sub}/**/*_spec.rb"
    end
  end

end


# Evergreen
# -----------------------------------------------------------------------------
require 'evergreen/tasks'


# Temporal
# -----------------------------------------------------------------------------
namespace :temporal do
  require 'uglifier'
  require 'sprockets-rails'

  desc "Builds Temporal into the distribution ready package"
  task :build => ['build:javascripts']

  namespace :build do

    desc "Combine javascripts into temporal.js and temporal.min.js"
    task :javascripts => :environment do
      env    = Rails.application.assets
      target = Pathname.new(File.join(Temporal::Engine.root.join('distro'), 'build'))
      manifest = {}

      ['temporal.js'].each do |path|
        env.each_logical_path do |logical_path|
          if path.is_a?(Regexp)
            next unless path.match(logical_path)
          else
            next unless File.fnmatch(path.to_s, logical_path)
          end

          if asset = env.find_asset(logical_path)
            manifest[logical_path] = asset.digest_path
            filename = target.join(asset.digest_path)
            mkdir_p filename.dirname
            asset.write_to(filename)
          end
        end
      end

      for base in ['temporal*.js']
        Dir[Temporal::Engine.root.join('distro/build', base)].each do |filename|
          copy_file(filename, Temporal::Engine.root.join("distro/#{base.gsub(/\*/, '')}"))
          minified = Uglifier.compile(File.read(filename))
          File.open(Temporal::Engine.root.join("distro/#{base.gsub(/\*/, '.min')}"), 'w') do |file|
            file.write(minified)
          end
          remove(filename)
        end
      end
    end

  end

end



Rake::Task['default'].prerequisites.clear
Rake::Task['default'].clear
task :default => [:spec, 'spec:javascripts']

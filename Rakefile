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

# Teabag
# -----------------------------------------------------------------------------
desc "Run javascript specs"
task :teabag => 'app:teabag'

# Temporal
# -----------------------------------------------------------------------------
namespace :temporal do
  desc "Builds Temporal into the distribution ready bundle"
  task :build => "build:javascripts"

  namespace :build do

    desc "Compile coffeescripts into javacripts"
    task :javascripts => :environment do
      env = Rails.application.assets

      %w(temporal.js).each do |path|
        asset = env.find_asset(path)
        asset.write_to(Temporal::Engine.root.join("distro/#{path}"))
        File.open(Temporal::Engine.root.join("distro/#{path.gsub(/\.js/, '.min.js')}"), 'w') do |file|
          file.write(Uglifier.compile(asset.source))
        end
      end
    end

  end

end

# Default
# -----------------------------------------------------------------------------
Rake::Task['default'].prerequisites.clear
Rake::Task['default'].clear

task :default => [:spec, :teabag]

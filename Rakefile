# frozen_string_literal: true

require "decidim/dev/common_rake"

def install_module(path)
  ENV["accountability_simple"] = ""
  Dir.chdir(path) do
    system("bundle exec rails decidim_favorites:install:migrations")
    system("bundle exec rails decidim_locations:install:migrations")
    system("bundle exec rails decidim_tags:install:migrations")
    system("bundle exec rails decidim_accountability_simple:install:migrations")
    system("bundle exec rails db:migrate")

    # Temporary fix to overcome the issue with sass-embedded, see:
    # https://github.com/decidim/decidim/pull/11074
    system("npm i sass-embedded@~1.62.0")
  end
end

# Temporary fix to overcome the issue with babel plugin updates, see:
# https://github.com/decidim/decidim/pull/10916
def fix_babel_config(path)
  Dir.chdir(path) do
    babel_config = "#{Dir.pwd}/babel.config.json"
    File.delete(babel_config) if File.exist?(babel_config)
    FileUtils.cp("#{__dir__}/babel.config.json", Dir.pwd)
  end
end

def seed_db(path)
  Dir.chdir(path) do
    system("bundle exec rake db:seed")
  end
end

desc "Generates a dummy app for testing"
task :test_app do
  ENV["accountability_simple"] = "create_app"
  ENV["RAILS_ENV"] = "test"
  generate_decidim_app(
    "spec/decidim_dummy_app",
    "--app_name",
    "#{base_app_name}_test_app",
    "--path",
    "../..",
    "--recreate_db",
    "--skip_gemfile",
    "--demo"
  )
  fix_babel_config("spec/decidim_dummy_app")
  install_module("spec/decidim_dummy_app")
end

desc "Generates a development app"
task :development_app do
  ENV["accountability_simple"] = "create_app"
  generate_decidim_app(
    "development_app",
    "--app_name",
    "#{base_app_name}_development_app",
    "--path",
    "..",
    "--recreate_db",
    "--demo"
  )
  fix_babel_config("development_app")
  install_module("development_app")
  seed_db("development_app")
end

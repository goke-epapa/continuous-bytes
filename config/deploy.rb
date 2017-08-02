# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'continuous_bytes'
set :repo_url, 'git@github.com:goke-epapa/continuous-bytes.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/html/continuous_bytes'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'content/apps', 'content/images', 'content/data'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :npm_flags, '--production'

namespace :deploy do
    desc "Symlink directories"
    task :create_symlink do
        on roles(:all) do |host|
            execute :mkdir, "#{current_path}/public"
            execute :ln, '-s', "#{current_path}/content/themes/casper/assets #{current_path}/public/assets"
            execute :ln, '-s', "#{current_path}/content/themes/casper/core/shared #{current_path}/public/shared"
        end
    end
end

namespace :deploy do
    desc "Writeable directories"
    task :writeable do
        on roles(:all) do |host|
            execute :chmod, "-R 777 #{deploy_to}/shared/content/apps"
            execute :chmod, "-R 777 #{deploy_to}/shared/content/images"
            execute :chmod, "-R 777 #{deploy_to}/shared/content/data"
            execute :chmod, "-R 777 #{current_path}/content/themes"
        end
    end
end

namespace :deploy do
    desc "Restart apache server"
    task :restart_apache do
        on roles(:all) do |host|
            execute :service, "apache2 restart"
        end
    end
end

namespace :npm do
    desc "Clear NPM cache"
    task :clear_cache do
        on roles(:all) do |host|
            execute :npm, "cache clean"
        end
    end
end

before 'npm:install', 'npm:clear_cache'
after :deploy, "deploy:create_symlink"
after :deploy, "deploy:writeable"
after :deploy, "deploy:restart_apache"
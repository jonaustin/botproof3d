require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require "rvm/capistrano"

ssh_options[:forward_agent] = true

set :application, "botproof3d"
set :repository,  "git@github.com:jonaustin/botproof3d.git"
set :use_sudo, false
set :deploy_via, :remote_cache

set :scm, :git
set :scm_passphrase, ""
set :user, "jon"

set :rvm_ruby_string, :local

role :web, "botproof3d.co"
role :app, "botproof3d.co"
role :db,  "botproof3d.co", :primary => true

set :stages, ["production"]
set :default_stage, "production"

before 'deploy', 'rvm:install_rvm'
before 'deploy', 'rvm:install_ruby'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

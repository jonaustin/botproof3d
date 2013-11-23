server 'botproof3d.co', :app, :web, :db, :primary => :true
set :deploy_to, '/opt/nginx/apps/botproof3d.co'

after "deploy:update_code", :configure_database
task :configure_database do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

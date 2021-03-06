server 'botproof3d.co', :app, :web, :db, :primary => :true
set :deploy_to, '/opt/nginx/apps/botproof3d.co'

# Devise needs access to the database.yml file before the assets are precompiled
before "deploy:assets:precompile", :symlinks
task :symlinks do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/public/uploads #{release_path}/public/uploads"
  run "ln -nfs #{shared_path}/public/mxls #{release_path}/public/mxls"
  run "ln -nfs #{release_path}/meshes #{release_path}/public/assets/meshes"
end

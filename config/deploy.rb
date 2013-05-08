#require 'hoptoad_notifier/capistrano'

default_run_options[:pty] = true

set :application, "originalprojects"
set :user, 'production'
set :use_sudo, false

role :web, "174.143.150.91"                          # Your HTTP server, Apache/etc
role :app, "174.143.150.91"                          # This may be the same as your `Web` server
role :db,  "174.143.150.91", :primary => true        # This is where Rails migrations will run

set :deploy_to, lambda { "/home/production/#{application}" }

set :scm, :git
set :repository, "git@github.com:originalprojects/originalprojects.git"
set :branch, "master"
set :migrate_target, :current

set :group_writable, false

#set(:latest_release) { fetch(:current_path) }
#set(:release_path) { fetch(:current_path) }
#set(:current_release) { fetch(:current_path) }
#
#set(:current_revision) { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
#set(:latest_revision) { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
#set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

#after "deploy:update_code", "search:symlink"
# after "deploy:update_code", "search:restart"

namespace :deploy do
  task :default do
    update
    restart
  end

  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to,  "/home/production/#{application}"]
    dirs += shared_children.map { |d| File.join( "/home/production/#{application}", d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{ "/home/production/#{application}"}"
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{ "/home/production/#{application}"}; git reset --hard #{branch};git pull"
    #finalize_update
    #bundle_gems
    #generate_database_yml
    compress_css_js
  end

  desc "Update the database (overwritten to avoid symlink)"
  task :migrations do
    update_code
    migrate
    restart
  end

  desc "Create the database.yml file"
#  task :generate_database_yml do
#    run "cd #{current_path}; cp config/database.yml-sample config/database.yml"
#  end

  desc "Deploy all the bundled gems"
#  task :bundle_gems do
#    run "cd #{current_path}; gem bundle --only production"
#  end

  desc "Compress JavaScript & CSS on the server"
  task :compress_css_js do
    rake "asset:packager:build_all"
  end

  desc "Remigrate & reseed DB"
  task :refresh_db do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    rake_cmd = "cd #{ "/home/production/#{application}"}; #{rake} RAILS_ENV=#{rails_env}"
    update_code
    rake "db:drop", "db:create", "db:migrate"
    rake "db:seed"
    restart
  end

  desc "Regenerate images and avatars"
  task :regen_images do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    rake_cmd = "cd #{ "/home/production/#{application}"}; #{rake} RAILS_ENV=#{rails_env}"
    rake "regen:avatars", "regen:images"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
       run "cd #{ "/home/production/#{application}"}; git revert HEAD^"
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{ "/home/production/#{application}"}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end

  task :start do; end
  task :stop do; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{"/home/production/#{application}"}/tmp/restart.txt"
 

  end
end

#namespace :search do
#  desc "create symlink for search index"
#  task :symlink do
#    rails_env = fetch(:rails_env, "production")
#    run "mkdir -p #{ "/home/production/#{application}"}/sphinx/#{rails_env}"
#    run "ln -nfs #{ "/home/production/#{application}"}/sphinx #{ "/home/production/#{application}"}/db/sphinx"
#  end
#
#  desc 'Restart the Sphinx server'
#  task :restart, :roles => :app do
#    rake "ts:config", "ts:stop"
#    rake "ts:index", "ts:start"
#  end
#end

desc "tail production log files"

task :tail_logs, :roles => :app do
  run "tail -f #{ "/home/production/#{application}"}/log/production.log"
#  do |channel, stream, data|
#    puts  # for an extra line break before the host name
#    puts "#{channel[:host]}: #{data}"
#    break if stream == :err
#  end
end

def rake(*cmd)
  rake = fetch(:rake, "rake")
  rails_env = fetch(:rails_env, "production")
  run "cd #{ "/home/production/#{application}"}; #{rake} RAILS_ENV=#{rails_env} #{cmd.join(' ')}"
end

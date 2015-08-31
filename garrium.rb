# Bode Fuwa
# Configure your rails app with preference of
# gems, set up git repository and commit to a repository

# Standard Gems 
# ==================================
# Analytics (https://github.com/segmentio/analytics-ruby)
gem "analytics-ruby"
# Password encryption
gem "bcrypt-ruby" 
# SASS mixins (http://bourbon.io/)
gem "bourbon"
# Authorization (https://github.com/ryanb/cancan)
gem "cancan"
# Templating engine
case ask("Choose Template Engine:", limited_to: %w[haml slim erb])
  when "haml"	
  	gem "haml-rails"
  when "slim"
  	gem "slim-rails"
  when "erb"
  	run 'echo \"Got it.\"'
end

# Development Environment Gems
# ==================================
gem_group :development do 
  # Clean up your errors
  gem "better_errors"
  # Choose test framework
  case ask("Choose testing framework:", limited_to: %w[rspec minitest])
    when "rspec"
  	  # use RSpec
  	  gem "rspec"
  	  gem "rspec-rails"
  	  gem "guard-rspec"
  	  gem "cucumber-rails"
  	  run "rails g rspec:install"
    when "minitest"
      # use MiniTest
  	  gem "minitest"
  	  gem "minitest-rails"
  end
end

# Test Environment Gems
# ==================================
gem_group :test do 
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'rb-fsevent', :require => false
  gem 'growl'
  gem 'guard-spork' 
  gem 'spork'
  gem 'launchy'
end

# Production Environment Gems
# ==================================
gem_group :production do 
  # For rails 4 deployment on Heroku
  # Set production database 
  case ask("Select Production Database", limited_to: %w[pg mysql])
    when "pg"
  	  gem "pg"
    when "mysql"
  	  gem "mysql"
  end
  # Select application server in production
  case ask("Select Production App Server", limited_to: %w[puma unicorn later])
    when "puma"  
      gem "puma"
    when "unicorn"
  	  gem "unicorn"
  	when "later"  
  end
end

# Set up Assets
# ==================================
# Add SASS extention to application.css
run "mv /app/assets/stylesheets/application.css /app/assets/stylesheets/application.css.scss"
# Remove require tree directives
run "sed -i '' /require_tree/d app/assets/javascripts/application.js"
run "sed -i '' /require_tree/d app/assets/stylesheets/application.css.scss"
# Add bourbon to stylesheet file
run "echo >> app/assets/stylesheets/application.css.scss"
run "echo '@import \"bourbon\";' >>  app/assets/stylesheets/application.css.scss"

# Install gems that are run
run "rails g cancan:ability"

# - Installs either [Angular js](), [Ember js]() or, [Backbone js]()
# ==================================
if yes?("Would you like to select a js framework? [yes no]")
  case ask("", limited_to: %w[backbone ember angular])
  when "backbone"
  	gem "rails-backbone"
    run "bundle install"
  	run "rails g backbone:install"
  when "ember"
  	gem 'ember-rails'
	gem 'ember-source'
  run "bundle install"
	run "rails generate ember:bootstrap" 
  when "angular"
  	gem "angular-rails"
    run "bundle install"
  	run "rails g angular:install"
  end
end

# Bootstrap or foundation
# also will_paginate
# =========================================
case ask("Would you like to install bootstrap and will paginate or zurb foundation?", limited_to: %w[bootstrap zurb])
  when "bootstrap"
    gem 'bootstrap-sass'
    gem 'will_paginate'
    gem 'bootstrap-will_paginate'
    run "bundle install"
    run "echo '@import \"bootstrap\";' >>  app/assets/stylesheets/application.css*"
  when "zurb"
  	gem "foundation-rails"
  	gem "kaminari"
    run "bundle install"
  	run "rails g foundation:install"
    run "echo '@import \"foundation_and_overrides\";' >>  app/assets/stylesheets/application.css*"
    run "echo '//= require foundation \n $(document).foundation();' >>  app/assets/javascripts/application.js"
    run "rails g kaminari:config"
end

# font-awesome
# ====================================
if yes?("Install font awesome? [yes no]")
  gem "font-awesome-rails"
  run "bundle install"
  # Add font-awesome to stylesheet file
  run "echo >> app/assets/stylesheets/application.css*"
  run "echo '@import \"font-awesome\";' >>  app/assets/stylesheets/application.css*"
end

# Install Active Model Serializers
# ==================================
if yes?("Install Active Model Serializers? [yes no]")
  gem 'active_model_serializers' 
end

# Grape and Grape-Swagger for APIs
# ==================================
if yes?("Do you want to install Grape and Grape-Swagger? [yes no]")
  gem 'grape'
  gem 'grape-active_model_serializers'
  gem 'grape-swagger-rails'
  gem 'rack-cors', require: 'rack/cors'
end

# Install Authentication utility
# ==================================
case ask("What authentication tool would you like?", limited_to: %w[devise omniauth other])
  when "devise"
    gem "devise"
    run "bundle install"
    run "rails generate devise:install"
  when "omniauth"
 	gem "omniauth-rails"
  when "other"
end

# Install Administrative tool
# ==================================
case ask("Install Upmin for administration?", limited_to: %w[upmin no])
  when "upmin"
  	gem "upmin-admin"
    run "bundle install"
  	run "rails g upmin:install"
  when "no"
end

# Setup automated deployment with 
# capistrano
# ==================================
if yes?("Would you like to install Capistrano? [yes no]")
  gem 'capistrano'#, '~> 3.2.1'
  gem 'capistrano-rails'#, '~> 1.1.1'
  gem 'capistrano-bundler'#, '~> 1.1.2'
  gem 'capistrano-rbenv'#, '~> 2.0.2'
  run "cap install"
end

# Run bundle
# ==================================
run "bundle install"

# Let's try to keep secret things 
# secret
# Ignore specific files in git
# ==================================
run "cat << EOF >> .gitignore
/.bundle
/db/*.sqlite3
/db/*.sqlite3-journal
/log/*
!/log/.keep
/tmp
/db/seeds.rb
/config/database.yml
database.yml
doc/
*.swp
*~
.project
.DS_Store
.idea
.secret
/config/secrets.yml
EOF"

# Setup git and a repository
# ==================================
git :init 
git add: "."
git commit: %Q{ -m 'Initial commit'}

if yes?("Initialize repository? [yes no]")
  git_uri =  'git config remote.origin.url'.strip	
  unless git_uri.size == 0
    say "A repository already exists for this project"
    say "#{git_uri}"
  else
    case ask("Choose your repository platform", limited_to: %w[github bitbucket])
      when "github"
        username = ask "GitHub username: "
      	run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
      	git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
      	git push: %Q{ origin master }
      when "bitbucket"
      	username = ask "Bitbucket username: "
      	# Keep an eye out for bitbucket's api versions.
      	run "curl --user #{username} '{\"name\":\"#{app_name}\"}' https://api.bitbucket.org/2.0/user/repositories"
      	git remote: %Q{ add origin git@bitbucket.org:#{username}/#{app_name}.git }
      	git push: %Q{ origin master }
    end
  end  	
end

# Setup heroku
# ==================================
if yes?("Set up heroku? [yes no]")
  run "heroku version"
  run "heroku login"
  run "heroku keys:add"
  run "heroku create"
  run "git push heroku master"
  run "heroku rename #{app_name}"
end
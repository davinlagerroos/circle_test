namespace :db do
  desc "Loads initial database models for the current environment."
  task :populate => :environment do
    #require 'active_record_extensions'
    Dir[File.join(Rails.root, 'db', 'populate', '*.rb')].sort.each do |fixture| 
      load fixture 
      puts "Loaded #{fixture}"
    end
    (Dir[File.join(Rails.root, 'db', 'populate', Rails.env, '*.rb')] + Dir[File.join(Rails.root, 'db', 'populate', 'shared', '*.rb')]).sort{|x,y| File.basename(x) <=> File.basename(y)}.each do |fixture|
      load fixture 
      puts "Loaded #{fixture}"
    end
    Dir[File.join(Rails.root, 'db', 'populate', 'after', '*.rb')].sort.each do |fixture| 
      load fixture 
      puts "Loaded #{fixture}"
    end
  end

  desc "Runs migrations and then loads seed data"
  task :migrate_and_populate => [ 'db:migrate', 'db:populate' ]

  task :migrate_and_load => [ 'db:migrate', 'db:populate' ]
  
  desc "Drop and reset the database for the current environment and then load seed data"
  task :reset_and_populate => [ 'db:reset', 'db:populate']

  task :reset_and_load => [ 'db:reset', 'db:populate']

  desc "load schema, migrate, populate and fixtures"
  namespace :dev do
    task :rebuild do
      system('rake db:schema:load')
      system('rake db:migrate')
      system('rake db:populate')
      system('rake redis:populate')
      system('rake db:fixtures:load')
      system('rake db:reset_sequences')
    end
  end
  
  desc "prepare,populate and fixtures"
  namespace :test do
    task :rebuild do
      system('rake db:schema:load RAILS_ENV=test')
      system('rake db:migrate RAILS_ENV=test')
      system('rake db:populate RAILS_ENV=test')
      system('rake redis:populate RAILS_ENV=test')
      system('rake db:fixtures:load RAILS_ENV=test')
      system('rake db:reset_sequences RAILS_ENV=test')
    end
  end
  
  desc "Reset all sequences. Run after data imports"
  # task :reset_sequences, :model_class, :needs => :environment do |t, args|
    task :reset_sequences, [:model_class] => [:environment] do |t, args|
    if args[:model_class]
      classes = Array(eval args[:model_class])
    else
      puts "using all defined active_record models"
      classes = []
      # Dir.glob(Rails.root + '/app/models/**/*.rb').each { |file| require file }
      Dir.glob(Rails.root.to_s + '/app/models/**/*.rb').each { |file| require file }
      ActiveRecord::Base.subclasses.select { |c|c.base_class == c}.sort_by(&:name).each do |klass|
        classes << klass
      end
    end
    classes.each do |klass|
      puts "reseting sequence on #{klass.table_name}"
      ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name)
    end
  end
  
  desc "Start posgres db that was installed with home brew"
  task :start do
    `pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start`
  end

  desc "Stop posgres db that was installed with home brew"
  task :stop do
    `pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log stop`
  end
end

namespace :bootstrap do
     desc "Add the default user"
     task :default_user => :environment do
     end

     desc "Run all bootstrapping tasks"
     task :all do
     end
end

namespace :svn do
  desc "create a tagged build from trunk. Pass tag param."
  task :tag do
    unless ENV.include?("tag")
      raise "usage: must include tag=[your_build_tag]"
    end
    tag_name = ENV['tag']
    `svn copy -m "Tagging branch #{tag_name}" $ssasvn/PayByPay/trunk $ssasvn/PayByPay/tags/#{tag_name}`
  end

  desc "create a branch from trunk. Pass branch param."
  task :branch do
    unless ENV.include?("branch")
      raise "usage: must include branch=[your_branch]"
    end
    branch_name = ENV['branch']
    `svn copy -m "Creating branch #{branch_name}" $ssasvn/PayByPay/trunk $ssasvn/PayByPay/branches/#{branch_name}`
  end
  
  desc "get branch point revision. Pass branch param."
  task :merge_point do
    unless ENV.include?("branch")
      raise "usage: must include branch=[your_branch]"
    end
    branch_name = ENV['branch']
    puts `svn log --stop-on-copy $ssasvn/PayByPay/branches/#{branch_name}`
  end

  desc "merge"
  task :merge do
    unless ENV.include?("branch") && ENV.include?("merge_point")
      raise "usage: must include branch=[your_branch] merge_point=[revision_number]"
    end
    branch_name = ENV['branch']
    merge_point = ENV['merge_point']
    puts `svn merge -r #{merge_point}:HEAD $ssasvn/PayByPay/branches/#{branch_name}`
    Rake::Task['asset:packager:build_all'].invoke
  end
  
  desc "Produce diff report on what you're about to get from svn up"
  task :preup do
    `svn diff -r BASE:HEAD > ~/Desktop/changes.txt && mate ~/Desktop/changes.txt`
  end
  
  namespace :promote do
    task :last_updated do
      a = `svn info $pxp#{@to_branch} | grep Rev:`.match(/: (\d+)/)
      @merge_point = a[1]
    end

    task :merge do
      `svn merge -r #{@merge_point}:HEAD $ssasvn/PayByPay/#{@from_branch} $pxp#{@to_branch}`
      Rake::Task['asset:packager:build_all'].invoke
    end

    desc "Promotes code from Dev to Review"
    task :to_review do
      @from_branch = 'dev'
      @to_branch = 'review'
      Rake::Task['svn:promote:last_updated'].invoke
      Rake::Task['svn:promote:merge'].invoke
    end
  
    desc "Promotes code from Review to Trunk"
    task :to_trunk do
      @from_branch = 'review'
      @to_branch = 'trunk'
      Rake::Task['svn:promote:last_updated'].invoke
      Rake::Task['svn:promote:merge'].invoke
    end

    desc "Updates Maintenance from Trunk"
    task :to_maintenance do
      @from_branch = 'trunk'
      @to_branch = 'maintenance'
      Rake::Task['svn:promote:last_updated'].invoke
      Rake::Task['svn:promote:merge'].invoke
    end
  end
end

namespace :test do

  Rake::TestTask.new(:units => "db:test:rebuild") do |t|
    t.libs << "test"
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end
  
  desc 'Measures test coverage'
  task :coverage do
    `rm -rf coverage*`
    # rcov = "rcov -Itest --rails --aggregate coverage.data -x \" rubygems/*,/Library/Ruby/Site/*,gems/*,rcov*\""

    rcov = "rcov -Itest --rails --aggregate coverage.data --text-summary "
    system("#{rcov} ./test/unit/*_test.rb")
    # system("#{rcov} test/unit/helpers/*_test.rb")
    # system("#{rcov} test/functional/*_test.rb")
    # system("#{rcov} test/integration/*_test.rb")
    system("open coverage/index.html") if PLATFORM['darwin']
  end
  
  task :report do
    system("open coverage/index.html") if PLATFORM['darwin']
  end

end

namespace :db do
end

namespace :redis do
  task :populate => :environment do
    $redis.flushall

    # Dir[File.join(Rails.root, 'db', 'redis', '*.rb')].sort.each do |fixture| 
    #   load fixture 
    #   puts "Loaded #{fixture}"
    # end
    
    $redis.set 'circleci_id', rand(100000)
  end
end

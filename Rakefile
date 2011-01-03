require './lib/simple_performer.rb'

begin
    require 'jeweler'
    Jeweler::Tasks.new do |gemspec|
        gemspec.name = "simple_performer"
        gemspec.summary = "Appoxy SimplePerformer Client Gem"
        gemspec.description = "Appoxy SimplePerformer Client Gem ..."
        gemspec.email = "travis@appoxy.com"
        gemspec.homepage = "http://www.appoxy.com"
        gemspec.authors = ["Travis Reeder"]
        gemspec.files = FileList['lib/**/*.rb']
#        gemspec.add_dependency 'simple_record'
        gemspec.add_dependency 'rest-client'
#        gemspec.add_dependency 'eventmachine'
    end
rescue LoadError
    puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gems.github.com"
end

task :bump_and_install do
    # bump version
    Rake::Task["version:bump:patch"].invoke
    Rake::Task["install"].invoke
end


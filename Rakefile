require './lib/simple_performr.rb'

begin
    require 'jeweler'
    Jeweler::Tasks.new do |gemspec|
        gemspec.name = "simple_performr"
        gemspec.summary = "Appoxy SimplePerformr Client Gem"
        gemspec.description = "Appoxy SimplePerformr Client Gem ..."
        gemspec.email = "travis@appoxy.com"
        gemspec.homepage = "http://www.appoxy.com"
        gemspec.authors = ["Travis Reeder"]
        gemspec.files = FileList['lib/**/*.rb']
#        gemspec.add_dependency 'simple_record'
        gemspec.add_dependency 'rest-client'
        gemspec.add_dependency 'eventmachine'
    end
rescue LoadError
    puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gems.github.com"
end

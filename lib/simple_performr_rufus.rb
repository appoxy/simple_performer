require 'rubygems'
require 'httpparty'
require 'rufus/scheduler'
require 'json'
module SimplePerformer
    class TimeBlock
        attr_reader :start_time, :end_time, :duration

        def initialize(start_time, end_time, duration)
            @start_time=start_time
            @end_time=end_time
            @duration=duration
        end
    end
    class PerformrRufus
        @@store = {}

        attr_reader :scheduler
        include HTTParty
        base_uri 'http://localhost:3000/api/metrics'
        format :json

        def initialize
            @scheduler = Rufus::Scheduler.start_new
        end

        def benchmark(name)
            start_time=Time.now
            yield
            end_time  =Time.now
            @@store[name] ||= []
            duration = start_time-end_time
            @@store[name] << TimeBlock.new(start_time, end_time, duration)
        end

        def send_updates
            scheduler do
                api_key = "1b27953c-1b9f-11df-af31-002618d9f74e"
                url = "/update_metrics"+"/"+api_key
                response=self.class.post(url, :query => {"metrics" => @@store.to_json})
                puts response
            end
        end
    end
end
p=SimplePerformer::PerformrRufus.new


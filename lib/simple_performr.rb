require 'rubygems'
require 'rest_client'
require 'eventmachine'
require 'benchmark'
require 'pp'
require 'json'
require 'base'
require 'data_array'
require 'api_auth'
require 'sp_rack'

#for Now data array would simply be a queue
module SimplePerformr

    # name is what this chunk of code will be referred to in the UI.
    def self.benchmark(name, & block)
        Performr.benchmark(name, & block)
    end

    def self.shutdown
        EventMachine.stop
    end

    class Performr #< ApiAuth

        class <<self

            attr_accessor :data, :api_key, :base_uri, :timer

            def config options={}, &blk
                self.api_key = options[:key]
                self.data = Queue.new
                self.base_uri='http://localhost:3000/api/metrics'

                puts api_key
                run_update
                instance_eval &blk if block_given?
            end

            def reset_queue
                self.data = Queue.new
            end

            def send_update
                puts "send_update api_key=" + api_key
                url = "/update_metrics/"+api_key
                #consumer for data
                #delete all data from queue after update
                to_send = return_data
                puts "sending json=" + to_send.inspect

                to_send = to_send.to_json
                puts 'posting to ' + full_url(url)
                response = RestClient.post(full_url(url), to_send, :content_type => :json)
            end

            def return_data
                avg_metrics = {}
                i=0
                data = self.data
                reset_queue # create a new one so the current queue doesn't have the opportunity to keep filling up and we try to keep popping too
                until data.empty?
                    metric=data.pop
                    name=metric[:name]
                    avg_metrics[name]  ||={:count => 0, :user => 0, :system => 0, :total => 0, :real => 0}
                    avg_metrics[name][:count]   += 1
                    avg_metrics[name][:user]    += metric[:user]
                    avg_metrics[name][:system]  += metric[:system]
                    avg_metrics[name][:total]   += metric[:total]
                    avg_metrics[name][:real]    += metric[:real]
                end
                #            puts hash.inspect + " hash inspect"
                avg_metrics
            end


            def full_url(path)
                base_uri + path
            end

            def periodic_update

                EventMachine.run do
                    @timer = EventMachine::PeriodicTimer.new(60) do
                        puts "the time is #{Time.now}"
                        begin
                            send_update
                        rescue => ex
                            puts ex.message
                            puts ex.backtrace
                        end

                    end
                end
            end

            def cancel_update
                timer.cancel if timer
            end


            def run_update
                Thread.new do
                    periodic_update
                end
            end

            def benchmark name, &block
                opts = name
                stat=Benchmark::measure &block
                puts 'name2=' + name.inspect
                if opts.is_a? Hash
                    name = opts[:name]
                end
                unless name && name.length > 0
                    raise "Must provide a name for benchmark."
                end
                puts 'name =' + name
                pp stat.to_hash, stat.class
                collect_stats stat.to_hash.merge(:name => name)
            end

            def collect_stats stat
                self.data.push(stat)
            end

        end
    end
end

class Benchmark::Tms
    def to_hash
        {
                :user => @utime,
                :real => @real,
                :total => @total,
                :system =>@stime
        }
    end
end


require 'rubygems'
require 'rest_client'
require 'eventmachine'
require 'benchmark'
require 'pp'
require 'json'
require_relative 'base'
require_relative 'data_array'
require_relative 'api_auth'
require_relative 'sp_rack'

#for Now data array would simply be a queue
module SimplePerformer

    @@metrics_path = '/api/metrics'
    @@base_url = 'http://incoming.simpleperformr.com' + @@metrics_path

    class << self
        attr_accessor :config,
                      :service

        def configure()
            SimplePerformer.config ||= SimplePerformer::Config.new
            yield(config)
#            SimplePerformer.service = Performr.new(config.access_key, config.secret_key, :config=>config)
            Performr.start
        end
    end

    # name is what this chunk of code will be referred to in the UI.
    def self.benchmark(name, &block)
        Performr.benchmark(name, &block)
    end

    def self.shutdown
        EventMachine.stop
    end

    def self.base_url=(url)
        @@base_url = url + @@metrics_path
    end

    def self.base_url
        @@base_url
    end

    # Simple function that simply spits out the duration of the block
    # - name is for reference.
    def self.puts_duration(name, &block)
        start_time = Time.now
        yield
        end_time = Time.now
        puts "#{name} duration: #{(end_time-start_time)} seconds."
    end

    class Performr
        #< ApiAuth

        class <<self

            attr_accessor :data, :api_key, :base_uri, :timer

            def config options={}, &blk
                SimplePerformer.configure do |config|
                    config.access_key = options[:access_key]
                    config.host = options[:host]
                end

                instance_eval &blk if block_given?
            end

            def start
                self.data = Queue.new

                puts "api_key=" + api_key.to_s
                if api_key
                    # only start it if we passed in a key
                    run_update
                end

            end

            def reset_queue
                self.data = Queue.new
            end

            def send_update
#                puts "send_update api_key=" + api_key
                url = "/update_metrics/"+api_key
                #consumer for data
                #delete all data from queue after update
                to_send = return_data
#                puts "sending json=" + to_send.inspect

                to_send = to_send.to_json
#                puts 'posting to ' + full_url(url)
                response = RestClient.post(full_url(url), to_send, :content_type => :json)
            end

            def return_data
                avg_metrics = {}
                i=0
                data = self.data
                reset_queue
                # create a new one so the current queue doesn't have the opportunity to keep filling up and we try to keep popping too
                until data.empty?
                    metric=data.pop
                    name=metric[:name]
                    avg_metrics[name] ||= {:count => 0, :user => 0, :system => 0, :total => 0, :real => 0}
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
                SimplePerformer.base_url + path
            end

            def periodic_update

                EventMachine.run do
                    @timer = EventMachine::PeriodicTimer.new(60) do
#                        puts "the time is #{Time.now}"
                        begin
                            send_update
                        rescue => ex
                            puts 'Failed to send data to SimplePerformr!'
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


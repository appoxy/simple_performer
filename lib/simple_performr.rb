require 'rubygems'
#require 'httparty'
require 'rest_client'
require 'eventmachine'
require 'benchmark'
require 'pp'
require 'json'
require File.dirname(__FILE__)+'/./rack/simple_performer'
#for Now data array would simply be a queue
module SimplePerformr

    class Base
        def log str
            puts str.to_s
        end
    end


    class Performr #< ApiAuth

        class <<self

            attr_accessor :data, :api_key, :base_uri, :timer

            def config options={}, & blk
                self.api_key = options[:key]
                self.data= Queue.new
                self.base_uri='http://localhost:3000/api/metrics'

                puts api_key
                run_update
                instance_eval & blk if block_given?
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

            def full_url(path)
                base_uri + path
            end

            def periodic_update

                EventMachine.run {
                    timer = EventMachine::PeriodicTimer.new(10) do
                        puts "the time is #{Time.now}"
                        begin
                            send_update
                        rescue => ex
                            puts ex.message
                            puts ex.backtrace
                        end


                    end
                }
                #end
            end

            def cancel_update
                timer.cancel if timer
            end


            #

            def return_data
                avg_metrics = {}
                i=0
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


            def run_update
                Thread.new do
                    periodic_update
                end
            end


            def benchmark name, & block
                stat=Benchmark::measure & block
                pp stat.to_hash, stat.class
                collect_stats stat.to_hash.merge(:name => "#{name[:controller].camelize}##{name[:action]}")
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


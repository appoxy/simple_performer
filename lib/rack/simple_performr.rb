require File.expand_path(File.dirname(__FILE__) + "../simple_performr") 
# I think rack middleware is ideal place to collect stats


# Rack is stack of middleware
# server middleware1(middleware2(middleware3( .... middlewareN (app)))
# Rack middleware is an object that responds to call method and could be intialized with other middleware
#
# How it works?
# middleware2 is intialized with middleware3
# when middleware1 is called by server
# middleware1 will call middleware2 and chain continues until the app is called and response 
# returned from app is returned back to server through middleware chain which is sent back as 
# response to request


module Rack
  
  class Performr
    
    def initialize(app, message = "Simple performer stats")
      @app = app
      @message = message
      @simple_performer= SimplePerformr::Performr.new
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @simple_performer.benchmark(name={}) do
        @status, @headers, @response = @app.call(env)
      end
      [@status, @headers, self]
    end
  
  end

end


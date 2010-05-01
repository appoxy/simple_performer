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
module SimplePerformr

    class Rack

      def initialize(app, message = "SimplePerformr stats")
        @app = app
        @message = message
      end

      def call(env)
        dup._call(env)
      end

      def _call(env)
        @request = {}
        Performr.benchmark(@request) do
          @response = @app.call(env)
          @request[:controller] = env['action_controller.request.path_parameters']['controller']
          @request[:action] = env['action_controller.request.path_parameters']['action']
        end
         @response
      end

  end
end

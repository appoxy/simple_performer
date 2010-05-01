require 'rubygems'
require 'call_stack'
require 'pp'
start_time=Time.now
call_stack_on    # start recording information   

#.... somewhere else
class Test
    def b
        foo
    end
end

def foo
    backtrace = call_stack(-1)
    pp backtrace
end

pp Test.new.b
call_stack_off
end_time=Time.now
puts end_time-start_time

start_time=Time.now

#.... somewhere else
class Test
    def b
        foo
    end
end

def foo
end

pp Test.new.b
end_time=Time.now
puts end_time-start_time

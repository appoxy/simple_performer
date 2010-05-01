require 'benchmark'

Benchmark.bm(8) do |r|
    $t=r.report {
        100000.times do |x|
            x=x+1
        end
    }
end


start_time= Time.now
100000.times do |x|
    x=x+1
end
end_time=Time.now
puts "normal: " + (end_time - start_time).to_s
puts "benchmark: "+ $t.real.to_s
puts "difference:  " + ($t.real- (end_time-start_time)).to_s

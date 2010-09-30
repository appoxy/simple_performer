
Getting Started
===============

In environment.rb:

    config.gem 'simple_performer'
    config.middleware.use SimplePerformer::Rack

To wrap your own sections:

    SimplePerformer.benchmark("name_of_code_section") do

    end

Other Utility Functions
-----------------------

To print duration of a block:

    SimplePerformer.puts_duration ("name_of_code_section") do

    end


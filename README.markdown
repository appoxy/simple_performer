
Getting Started
===============

In environment.rb:

    config.gem 'simple_performr'
    config.middleware.use SimplePerformr::Rack

To wrap your own sections:

    SimplePerformr.benchmark("name_of_code_section") do

    end

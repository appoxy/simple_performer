# Add special route for checking performance at '/simple_performer'


# This is commented out now because we can use the Rack loader now.
=begin

puts "Loading performer..."

controllers = Dir.new("#{RAILS_ROOT}/app/controllers").entries
controllers.each do |controller|

  if controller =~ /_controller/
    cont = controller.camelize.gsub(".rb","")

    cont.constantize.class_eval do

      (action_methods-superclass.action_methods).each do |each_method|
          alias :"old_#{each_method}" :"#{each_method}"
          puts "wrapping #{cont}##{each_method}"
          eval <<-EOD
          def #{each_method} *args
            puts "wrapped ------------- #{cont}##{each_method}"
            PERFORMER.benchmark("#{cont}##{each_method}") do
              old_#{each_method} *args
            end
          end
         EOD
         
      end

    end

  end

end
=end

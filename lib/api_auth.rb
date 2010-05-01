module SimplePerformr
  class ApiAuth
    attr_accessor :host
    def initialize(access_key, secret_key="default", options={})
      @access_key = access_key
      @secret_key = secret_key
      @host = options[:host] 
    end
  end 
end 


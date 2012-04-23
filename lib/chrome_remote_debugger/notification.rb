class ChromeRemoteDebugger
  class Notification

    attr_reader :method

    def initialize(point)
      @params = point['params']
      @method = point['method']
    end

    def resource_type
      @params['type'] if @params
    end

  end
end

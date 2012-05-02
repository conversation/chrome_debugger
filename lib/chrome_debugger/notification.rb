module ChromeDebugger
  class Notification

    attr_reader :method

    def initialize(point)
      @params = point['params'] || {}
      @method = point['method']
    end

    def resource_type
      @params['type']
    end

    def request_id
      @params['requestId']
    end

  end
end

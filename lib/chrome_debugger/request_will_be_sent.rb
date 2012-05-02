require 'chrome_debugger/notification'

module ChromeDebugger
  class RequestWillBeSent < Notification

    def request
      @params['request']
    end

    def timestamp
      @params['timestamp'].to_f
    end
  end
end

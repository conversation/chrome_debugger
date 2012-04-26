require 'chrome_debugger/notification'

module ChromeDebugger
  class ResponseReceived < Notification

    def bytes
      @params['response']['headers']['Content-Length'].to_i
    end

  end
end

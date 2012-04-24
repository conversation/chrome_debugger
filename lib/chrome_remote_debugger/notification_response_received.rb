require 'chrome_remote_debugger/notification'

class ChromeRemoteDebugger
  class ResponseReceived < Notification

    def bytes
      @params['response']['headers']['Content-Length'].to_i
    end

  end
end

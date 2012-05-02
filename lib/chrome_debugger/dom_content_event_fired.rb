require 'chrome_debugger/notification'

module ChromeDebugger
  class DomContentEventFired < Notification

    def timestamp
      @params['timestamp'].to_f
    end
  end
end

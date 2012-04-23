require 'chrome_remote_debugger/notification'
require 'chrome_remote_debugger/notification_response_received'

class ChromeRemoteDebugger
  class Document

    attr_accessor :timestamp, :network, :events

    def initialize
      @timestamp = 0
      @events = {}
      @network = []
    end

    def size(resource_type)
      @network.select {|n|
        n.is_a?(ResponseReceived) && n.resource_type == resource_type
      }.inject(0) {|bytes_sum, n| bytes_sum + n.bytes }
    end

    def request_count
      @network.select {|n|
        n.is_a?(ResponseReceived)
      }.size
    end

    def request_count_by_resource(resource_type)
      @network.select {|n|
        n.is_a?(ResponseReceived) && n.resource_type == resource_type
      }.size
    end

    def onload_event
      (@events[:onload_fired] - @timestamp).round(3)
    end

    def dom_content_event
      (@events[:dom_content_fired] - @timestamp).round(3)
    end

  end
end

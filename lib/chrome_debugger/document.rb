require 'chrome_debugger/dom_content_event_fired'
require 'chrome_debugger/load_event_fired'
require 'chrome_debugger/notification'
require 'chrome_debugger/response_received'
require 'chrome_debugger/request_will_be_sent'

module ChromeDebugger
  class Document

    attr_reader :url, :events

    def initialize(url)
      @url       = url
      @timestamp = 0
      @events    = []
    end

    # The seconds since epoch that the request for this document started
    #
    def start_time
      @start_time ||= @events.select { |event|
        event.is_a?(RequestWillBeSent)
      }.select { |event|
        event.request['url'] == @url
      }.map { |event|
        event.timestamp
      }.first
    end

    # The number of seconds *after* start_time that the OnLoad event fired
    #
    def onload_event
      @onload_event ||= begin
                          ts = @events.select { |event|
                            event.is_a?(LoadEventFired)
                          }.slice(0,1).map(&:timestamp).first
                          ts ? (ts - start_time).round(3) : nil
                        end
    end

    # The number of seconds *after* start_time the the DomReady event fired
    #
    def dom_content_event
      @dom_content_event ||= begin
                               ts = @events.select { |event|
                                 event.is_a?(DomContentEventFired)
                               }.slice(0,1).map(&:timestamp).first
                               ts ? (ts - start_time).round(3) : nil
                             end
    end

    # The number of bytes downloaded for a particular resources type.
    #
    # Possible resource types: 'Script', 'Image', 'Stylesheet'
    #
    def size(resource_type)
      @events.select {|n|
        n.is_a?(ResponseReceived) && n.resource_type == resource_type
      }.inject(0) {|bytes_sum, n| bytes_sum + n.bytes }
    end

    # The number of network requests required to load this document
    #
    def request_count
      @events.select {|n|
        n.is_a?(ResponseReceived)
      }.size
    end

    # the number of network requests of a particular resource
    # type that were required to load this document
    #
    # Possible resource types: 'Script', 'Image', 'Stylesheet'
    #
    def request_count_by_resource(resource_type)
      @events.select {|n|
        n.is_a?(ResponseReceived) && n.resource_type == resource_type
      }.size
    end

  end
end

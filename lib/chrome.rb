require 'em-http'
require 'faye/websocket'
require 'json'
require 'document'
require 'notification'
require 'notification_response_received'

class ChromeRemoteDebugger

  attr_reader :document

  PAGE_LOAD_WAIT = 16
  REMOTE_DEBUGGING_PORT = 9222

  def initialize(url)
    @url = url
    @document = Document.new
    load()
  end

  private

  def handle_data(data)
    unless data['result']
      case data['method']

      # The browser is initiating a new HTTP request
      when "Network.requestWillBeSent" then
        if data['params']['request']['url'] == @url
          page_request_timestamp = data['params']['timestamp'].to_f
          @document.timestamp = page_request_timestamp
        end

      # DomContent Events has been fired
      when "Page.domContentEventFired" then
        @document.events[:dom_content_fired] = data['params']['timestamp'].to_f

      # onLoad Event has been fired
      when "Page.loadEventFired" then
        @document.events[:onload_fired] = data['params']['timestamp'].to_f

      when "Network.responseReceived" then
        @document.network << ResponseReceived.new(data)

      else
        @document.network << Notification.new(data)
      end
    end
  end

  def load
    EM.run do

      # This is super smelly :/
      EM::add_timer PAGE_LOAD_WAIT do
        stop_event_loop
      end

      conn = EM::HttpRequest.new("http://localhost:#{REMOTE_DEBUGGING_PORT}/json").get
      conn.callback do
        response = JSON.parse(conn.response)

        ws = Faye::WebSocket::Client.new response.first['webSocketDebuggerUrl']

        ws.onmessage = lambda do |message|
          data = JSON.parse(message.data)
          handle_data(data)
        end

        ws.onopen = lambda do |event|
          ws.send JSON.dump({id: 1, method: 'Page.enable'})
          ws.send JSON.dump({id: 2, method: 'Network.enable'})
          ws.send JSON.dump({id: 3, method: 'Network.setCacheDisabled', params: {cacheDisabled: true}})
          ws.send JSON.dump({id: 4, method: 'Network.clearBrowserCache'})
          ws.send JSON.dump({
            id: 5,
            method: 'Page.navigate',
            params: {url: @url}
          })
        end
      end
    end
  end

  def stop_event_loop
    EM.stop_event_loop
  end

end

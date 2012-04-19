require 'em-http'
require 'faye/websocket'
require 'json'
require 'document'
require 'notification'
require 'notification_response_received'
require 'securerandom'

class ChromeRemoteDebugger

  attr_reader :document

  PAGE_LOAD_WAIT = 16
  REMOTE_DEBUGGING_PORT = 9222

  def initialize(opts = {})
    @chrome_path = find_chrome_binary
    @profile_dir = File.join(Dir.tmpdir, SecureRandom.hex(10))
    @chrome_pid  = start_chrome
  end

  def load_url(url)
    @document = Document.new
    load(url)
  end

  def cleanup
    Process.kill('-TERM', Process.getpgid(@chrome_pid))
    sleep 3
    FileUtils.rm_rf(@profile_dir) if File.directory?(@profile_dir)
  end

  private

  def start_chrome
    chrome_pid = Process.spawn("#{@chrome_path} --user-data-dir=#{@profile_dir} -remote-debugging-port=9222 --no-first-run", :pgroup => true)

    # TODO proper detection of a running chrome process
    sleep 2
    chrome_pid
  end

  def find_chrome_binary
    path = [
      "/usr/bin/google-chrome",
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    ].detect { |path|
      File.file?(path)
    }
    raise "No Chrome binary found" if path.nil?
    path
  end

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

  def load(url)
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
            params: {url: url}
          })
        end
      end
    end
  end

  def stop_event_loop
    EM.stop_event_loop
  end

end

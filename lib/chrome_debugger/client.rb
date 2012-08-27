require 'em-http'
require 'faye/websocket'
require 'headless'
require 'json'

require 'securerandom'

require 'chrome_debugger/document'
require 'chrome_debugger/notification'
require 'chrome_debugger/data_received'
require 'chrome_debugger/dom_content_event_fired'
require 'chrome_debugger/load_event_fired'
require 'chrome_debugger/request_will_be_sent'
require 'chrome_debugger/response_received'

module ChromeDebugger
  class Client

    PAGE_LOAD_WAIT = 16
    REMOTE_DEBUGGING_PORT = 9222

    def initialize(opts = {})
      @chrome_path = find_chrome_binary
    end

    def self.open(&block)
      headless = Headless.new
      headless.start
      chrome = ChromeDebugger::Client.new
      chrome.start_chrome
      yield chrome
    ensure
      chrome.cleanup
      headless.destroy
    end

    def start_chrome
      @profile_dir = File.join(Dir.tmpdir, SecureRandom.hex(10))
      @chrome_cmd  = "'#{@chrome_path}' --user-data-dir=#{@profile_dir} -remote-debugging-port=#{REMOTE_DEBUGGING_PORT} --no-first-run"
      @chrome_pid  = Process.spawn(@chrome_cmd, :pgroup => true)

      until debug_port_listening?
        sleep 0.1
      end
    end

    def load_url(url)
      raise "call the start_chrome() method first" unless @chrome_pid
      document = ChromeDebugger::Document.new(url)
      load(document)
      document
    end

    def cleanup
      if @chrome_pid
        Process.kill('-TERM', Process.getpgid(@chrome_pid))
        sleep 3
        FileUtils.rm_rf(@profile_dir) if @profile_dir && File.directory?(@profile_dir)
        @chrome_pid = nil
      end
    end

    private

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

    def handle_data(document, data)
      unless data['result']
        case data['method']
        when "Network.requestWillBeSent" then
          # The browser is initiating a new HTTP request
          document.events << ChromeDebugger::RequestWillBeSent.new(data)
        when "Page.domContentEventFired" then
          document.events << ChromeDebugger::DomContentEventFired.new(data)
        when "Page.loadEventFired" then
          document.events << ChromeDebugger::LoadEventFired.new(data)
        when "Network.responseReceived" then
          document.events << ChromeDebugger::ResponseReceived.new(data)
        when "Network.dataReceived" then
          document.events << ChromeDebugger::DataReceived.new(data)
        else
          document.events << ChromeDebugger::Notification.new(data)
        end
      end
    end

    def load(document)
      EM.run do
        EM::add_periodic_timer(0.5) do
          EM.stop_event_loop if document.onload_event
        end

        conn = EM::HttpRequest.new("http://localhost:#{REMOTE_DEBUGGING_PORT}/json").get
        conn.callback do
          response = JSON.parse(conn.response)

          ws = Faye::WebSocket::Client.new response.first['webSocketDebuggerUrl']

          ws.onmessage = lambda do |message|
            data = JSON.parse(message.data)
            handle_data(document, data)
          end

          ws.onopen = lambda do |event|
            ws.send JSON.dump({id: 1, method: 'Page.enable'})
            ws.send JSON.dump({id: 2, method: 'Network.enable'})
            ws.send JSON.dump({id: 3, method: 'Network.setCacheDisabled', params: {cacheDisabled: true}})
            ws.send JSON.dump({id: 4, method: 'Network.clearBrowserCache'})
            ws.send JSON.dump({
              id: 5,
              method: 'Page.navigate',
              params: {url: document.url}
            })
          end
        end
      end
    end

    def debug_port_listening?
      TCPSocket.new('localhost', REMOTE_DEBUGGING_PORT).close
      true
    rescue Errno::ECONNREFUSED
      false
    end

  end
end

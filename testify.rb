$LOAD_PATH.unshift(File.expand_path('../config', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'chrome'
require 'configuration'
require 'librato_updater'

CHROME_PATH = '"google-chrome"'

class Testify

  def initialize
    librato_updater = LibratoUpdater.new

    Configuration.instance.config['pages'].collect {|name, url|
      chrome = ChromeRemoteDebugger.new url
      {
        requests:             chrome.document.request_count,
        onload_event:         chrome.document.onload_event,
        dom_content_event:    chrome.document.dom_content_event,
        script_payload:       chrome.document.size("Script"),
        image_payload:        chrome.document.size("Images"),
        stylesheet_payload:   chrome.document.size("Stylesheet"),
        script_count:         chrome.document.request_count_by_resource("Script"),
        image_count:          chrome.document.request_count_by_resource("Images"),
        stylesheet_count:     chrome.document.request_count_by_resource("Stylesheet")
      }.each {|key, value| librato_updater.queue "#{name}.#{key}", value }
    }
    librato_updater.submit()
  end

end

chrome_pid = Process.spawn("#{CHROME_PATH} --user-data-dir=/tmp/temp-profile -remote-debugging-port=9222", :pgroup => true)
sleep 2
testify = Testify.new

Process.kill('-TERM', Process.getpgid(chrome_pid))

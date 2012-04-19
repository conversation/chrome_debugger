$LOAD_PATH.unshift(File.expand_path('../config', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'chrome'
require 'configuration'
require 'librato_updater'

librato_updater = LibratoUpdater.new

Configuration.instance.config['pages'].each do |name, url|
  chrome = ChromeRemoteDebugger.new
  begin
    chrome.load_url(url)
    {
      requests:             chrome.document.request_count,
      onload_event:         chrome.document.onload_event,
      dom_content_event:    chrome.document.dom_content_event,
      script_payload:       chrome.document.size("Script"),
      image_payload:        chrome.document.size("Image"),
      stylesheet_payload:   chrome.document.size("Stylesheet"),
      script_count:         chrome.document.request_count_by_resource("Script"),
      image_count:          chrome.document.request_count_by_resource("Image"),
      stylesheet_count:     chrome.document.request_count_by_resource("Stylesheet")
    }.each {|key, value|
      librato_updater.queue("#{name}.#{key}", value)
    }
  ensure
    chrome.cleanup
  end
end

librato_updater.submit()

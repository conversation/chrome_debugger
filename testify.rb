$LOAD_PATH.unshift(File.expand_path('../config', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'chrome'
require 'librato_updater'

# Config

LIBRATO_USER = ""
LIBRATO_KEY  = ""
PAGES        = {
  homepage: 'https://theconversation.edu.au/',
  articlepage: 'https://theconversation.edu.au/bike-lanes-economic-benefits-go-beyond-jobs-6081/'
}

# ACTION

librato_updater = LibratoUpdater.new(LIBRATO_USER, LIBRATO_KEY)

PAGES.each do |name, url|
  ChromeRemoteDebugger.open do |chrome|
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
  end
end

librato_updater.submit()

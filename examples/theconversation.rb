require 'chrome_debugger'

PAGES          = {
  homepage: 'https://theconversation.edu.au/',
  articlepage: 'https://theconversation.edu.au/bike-lanes-economic-benefits-go-beyond-jobs-6081/'
}

PAGES.each do |name, url|
  ChromeDebugger::Client.open do |chrome|
    document = chrome.load_url(url)
    {
      requests:             document.request_count,
      onload_event:         document.onload_event,
      dom_content_event:    document.dom_content_event,
      document_payload:     document.encoded_bytes("Document"),
      script_payload:       document.encoded_bytes("Script"),
      image_payload:        document.encoded_bytes("Image"),
      stylesheet_payload:   document.encoded_bytes("Stylesheet"),
      other_payload:        document.encoded_bytes("Other"),
      document_uncompressed_payload:   document.bytes("Document"),
      script_uncompressed_payload:     document.bytes("Script"),
      image_uncompressed_payload:      document.bytes("Image"),
      stylesheet_uncompressed_payload: document.bytes("Stylesheet"),
      other_uncompressed_payload:      document.bytes("Other"),
      script_count:         document.request_count_by_resource("Script"),
      image_count:          document.request_count_by_resource("Image"),
      stylesheet_count:     document.request_count_by_resource("Stylesheet")
    }.each {|key, value|
      puts "#{name}.#{key}: #{value}"
    }
  end
end

# Chrome Debugger

Ever wanted to capture stats (#requests, onload time, etc.) about the state of your frontend? Us too!
Chrome Debugger uses the remote debugging protocol in Chrome to do just that!

Intended to be a used in a post-deploy or CI step.

Yay-hooray!

## Installation

    gem install chrome_debugger

## Extra Requirements

Chrome 18 or higher must be installed and available on the path.

## Usage

    require 'chrome_debugger'

    ChromeDebugger::Client.open do |chrome|
      document = chrome.load_url("https://theconversation.edu.au/")

      puts "requests:          #{document.request_count}"
      puts "onload_event:      #{document.onload_event}"
      puts "dom_content_event: #{document.dom_content_event}"
      puts "document_payload:  #{document.encoded_bytes("Document")}"
      puts "script_payload:    #{document.encoded_bytes("Script")}"
      puts "image_payload:     #{document.encoded_bytes("Image")}"
    end

Refer to the ChromeDebugger::Client and ChromeDebugger::Document for detailed
docs.

ChromeDebugger::Client starts and manages a new chrome session.

ChromeDebugger::Document provides an entry point for querying the results of
a page load.

## Authors

Justin Morris
  justin.morris@theconversation.edu.au

James Healy
  james.healy@theconversation.edu.au

## Further Reading

* https://developers.google.com/chrome-developer-tools/docs/remote-debugging
* http://www.igvita.com/2012/04/09/driving-google-chrome-via-websocket-api/

## TODO

Possible further work.

* make the chrome path configurable
* make headless mode configurable

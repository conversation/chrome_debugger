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

```ruby
require 'chrome_debugger'

ChromeDebugger::Client.open do |chrome|
  document = chrome.load_url("https://theconversation.edu.au/")

  puts "request count:                      #{document.request_count}"
  puts "onload event fired:                 #{document.onload_event}"
  puts "dom content event fired:            #{document.dom_content_event}"
  puts "payload document encoded bytes:     #{document.encoded_bytes("Document")}"
  puts "payload script encoded bytes:       #{document.encoded_bytes("Script")}"
  puts "payload image encoded bytes:        #{document.encoded_bytes("Image")}"
  puts "payload stylesheet encoded bytes:   #{document.encoded_bytes("Stylesheet")}"
  puts "payload other encoded bytes:        #{document.encoded_bytes("Other")}"
  puts "payload document bytes:             #{document.bytes("Document")}"
  puts "payload script bytes:               #{document.bytes("Script")}"
  puts "payload image bytes:                #{document.bytes("Image")}"
  puts "payload stylesheet bytes:           #{document.bytes("Stylesheet")}"
  puts "payload other bytes:                #{document.bytes("Other")}"
  puts "script requests:                    #{document.request_count_by_resource("Script")}"
  puts "image requests:                     #{document.request_count_by_resource("Image")}"
  puts "stylesheet requests:                #{document.request_count_by_resource("Stylesheet")}"
end
```

Refer to the `ChromeDebugger::Client` and `ChromeDebugger::Document` classes for
detailed docs.

`ChromeDebugger::Client` starts and manages a new chrome session.

`ChromeDebugger::Document` provides an entry point for querying the results of
a page load.

## Authors

### Justin Morris
- justin.morris@theconversation.edu.au
- [@plasticine](http://twitter.com/plasticine)

### James Healy
- james@yob.id.au
- [@jim_healy](http://twitter.com/jim_healy)

## Further Reading

* https://developers.google.com/chrome-developer-tools/docs/remote-debugging
* http://www.igvita.com/2012/04/09/driving-google-chrome-via-websocket-api/

## TODO

Possible further work.

* make the chrome path configurable
* make headless mode configurable
 
## License

chrome_debugger is Copyright (c) 2012 The Conversation Media Group and distributed under the MIT license.

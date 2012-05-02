require 'chrome_debugger/notification'

module ChromeDebugger
  class DataReceived < Notification

    # uncompressed bytes in the HTTP content. Excludes HTTP headers
    #
    def data_length
      @params['dataLength'].to_i
    end

    # bytes received over the wire. Includes HTTP headers
    # and HTTP content. The HTTP content may be compressed.
    #
    def encoded_data_length
      @params['encodedDataLength'].to_i
    end
  end
end

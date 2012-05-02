require 'chrome_debugger/notification'

module ChromeDebugger
  class DataReceived < Notification

    # uncompressed bytes received
    #
    def data_length
      @params['dataLength'].to_i
    end

    # compressed bytes received
    #
    def encoded_data_length
      @params['encodedDataLength'].to_i
    end
  end
end

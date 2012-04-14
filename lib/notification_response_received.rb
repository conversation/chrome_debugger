require 'notification'

class ResponseReceived < Notification

  def bytes
    p
    @params['response']['headers']['Content-Length'].to_i
  end

end

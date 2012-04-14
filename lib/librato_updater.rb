require 'librato/metrics'
require 'configuration'

class LibratoUpdater

  LIBRATO_METRIC_PREFIX = "tc.frontend"

  def initialize
    @queue = Librato::Metrics::Queue.new
    config = Configuration.instance.librato
    Librato::Metrics.authenticate config['api_user'], config['api_key']
  end

  def queue(key, value)
    puts "#{LIBRATO_METRIC_PREFIX}.#{key} - #{value}"
    @queue.add "#{LIBRATO_METRIC_PREFIX}.#{key}" => value
  end

  def submit
    @queue.submit
  end

end

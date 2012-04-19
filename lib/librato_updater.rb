require 'librato/metrics'

class LibratoUpdater

  LIBRATO_METRIC_PREFIX = "tc.frontend"

  def initialize(user, key)
    @queue = Librato::Metrics::Queue.new
    Librato::Metrics.authenticate user, key
  end

  def queue(key, value)
    puts "#{LIBRATO_METRIC_PREFIX}.#{key} - #{value}"
    @queue.add "#{LIBRATO_METRIC_PREFIX}.#{key}" => value
  end

  def submit
    @queue.submit
  end

end

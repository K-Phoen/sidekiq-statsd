module Sidekiq::Statsd
  class ServerMiddleware
    def initialize(options = {})
      @options = {
        prefix: 'sidekiq',
        sidekiq_stats: true
      }.merge options

      @statsd = options[:statsd]
      @sidekiq_stats = Sidekiq::Stats.new if @options[:sidekiq_stats]
    end

    def call(worker, msg, queue)
      worker_name = worker.class.name.gsub('::', '.')

      begin
        @statsd.time prefix(worker_name, 'processing_time') do
          yield
        end

        @statsd.increment prefix(worker_name, 'success')
      rescue => e
        @statsd.increment prefix(worker_name, 'failure')
        raise e
      ensure
        send_global_stats if @options[:sidekiq_stats]
      end
    end

    private

    def send_global_stats
      # Queue sizes
      @statsd.gauge(prefix('enqueued'), @sidekiq_stats.enqueued)
      @statsd.gauge(prefix('retry_set_size'), @sidekiq_stats.retry_size)

      # All-time counts
      @statsd.gauge(prefix('processed'), @sidekiq_stats.processed)
      @statsd.gauge(prefix('failed'), @sidekiq_stats.failed)
    end

    def prefix(*args)
      [@options[:prefix], *args].compact.join('.')
    end
  end
end

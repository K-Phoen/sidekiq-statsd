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

      @statsd.batch do |b|
        begin
          b.time prefix(worker_name, 'processing_time') do
            yield
          end

          b.increment prefix(worker_name, 'success')
        rescue => e
          b.increment prefix(worker_name, 'failure')
          raise e
        ensure
          send_global_stats(b) if @options[:sidekiq_stats]
        end
      end
    end

    private

    def send_global_stats(statsd)
      # Queue sizes
      statsd.gauge(prefix('enqueued'), @sidekiq_stats.enqueued)
      statsd.gauge(prefix('retry_set_size'), @sidekiq_stats.retry_size)

      # All-time counts
      statsd.gauge(prefix('processed'), @sidekiq_stats.processed)
      statsd.gauge(prefix('failed'), @sidekiq_stats.failed)
    end

    def prefix(*args)
      [@options[:prefix], *args].compact.join('.')
    end
  end
end

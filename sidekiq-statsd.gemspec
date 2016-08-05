Gem::Specification.new do |s|
  s.name        = 'sidekiq-statsd'
  s.version     = '0.0.1'
  s.authors     = ['TEA']
  s.email       = 'technique@tea-ebook.com'
  s.license     = 'LGPL-3.0'
  s.homepage    = 'https://github.com/K-Phoen/sidekiq-statsd'
  s.summary     = 'Sidekiq middleware to send metrics to Statsd'
  s.description = 'Sidekiq middleware to send metrics to Statsd'
  s.require_paths = ['lib']

  s.files = `git ls-files`.split($\)
  s.test_files  = []

  s.add_dependency 'sidekiq', '~> 3'
end

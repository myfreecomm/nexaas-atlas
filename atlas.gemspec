# frozen_string_literal: true

lib_dir = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'atlas/version'

Gem::Specification.new do |spec|
  spec.name     = 'atlas'
  spec.version  = Atlas::VERSION
  spec.authors  = ['Nexaas Team']
  spec.email    = ['comercial@nexaas.com']
  spec.summary  = 'Ruby framework based on Hanami and dry-rb'
  spec.homepage = 'https://github.com/myfreecomm/nexaas-atlas'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'delayed_job'
  spec.add_dependency 'delayed_job_mongoid'
  spec.add_dependency 'dry-configurable', '0.8.2'
  spec.add_dependency 'dry-validation', '0.13.1'
  spec.add_dependency 'httparty'
  spec.add_dependency 'i18n', '1.6.0'
  spec.add_dependency 'ice_nine'
  spec.add_dependency 'json-serializer'
  spec.add_dependency 'hanami-controller', '~> 1.3.3'
  spec.add_dependency 'mongoid', '~> 6.1.0'
  spec.add_dependency 'pdfkit'
  spec.add_dependency 'rack', '~> 2.2.2'
  spec.add_dependency 'redis'
  spec.add_dependency 'sidekiq'
  spec.add_dependency 'wkhtmltopdf-binpath'

  spec.required_ruby_version = '>= 2.5.1'
end

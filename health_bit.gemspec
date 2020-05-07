# frozen_string_literal: true

require_relative 'lib/health_bit/version'

Gem::Specification.new do |spec|
  spec.name          = 'health_bit'
  spec.version       = HealthBit::VERSION
  spec.authors       = ['Aliaksandr Shylau']
  spec.email         = %w[alex.shilov.by@gmail.com]

  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = 'https://github.com/shlima/health_bit'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency 'rack'
end

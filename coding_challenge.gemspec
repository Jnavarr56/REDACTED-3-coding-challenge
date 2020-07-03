# frozen_string_literal: true

require_relative 'lib/coding_challenge/version'

Gem::Specification.new do |spec|
  spec.name          = 'coding_challenge'
  spec.license       = 'MIT'
  spec.version       = CodingChallenge::VERSION
  spec.authors       = ['Jorge Navarro']
  spec.email         = ['jnavarr56@gmail.com']

  spec.summary       = 'A hiring coding challenge.'
  spec.description   = 'A Ruby CLI app made for hiring coding challenge.'
  spec.homepage      = 'https://github.com/Jnavarr56/REDACTED-3-coding-challenge'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # blank for now
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Jnavarr56/REDACTED-3-coding-challenge'

  # blank for now
  spec.metadata['changelog_uri'] = 'https://github.com/Jnavarr56/REDACTED-3-coding-challenge'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Here's the stuff that does the pretty color magic and animations!
  spec.add_runtime_dependency 'colorize', '~> 0.8.1'
  spec.add_runtime_dependency 'lolcat', '~> 100.0', '>= 100.0.1'
  spec.add_runtime_dependency 'thor', '~> 1.0', '>= 1.0.1'
  spec.add_runtime_dependency 'tty-progressbar', '~> 0.17.0'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.21.0'
  spec.add_runtime_dependency 'tty-spinner', '~> 0.9.3'
end

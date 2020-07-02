require_relative 'lib/coding_challenge/version'

Gem::Specification.new do |spec|
  spec.name          = "coding_challenge"
  spec.license       = "MIT"
  spec.version       = CodingChallenge::VERSION
  spec.authors       = ["Jorge Navarro"]
  spec.email         = ["jnavarr56@gmail.com"]

  spec.summary       = %q{TODO: Write a short summary, because RubyGems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  # Here's the stuff that does the pretty color magic!
  spec.add_runtime_dependency 'figlet', '~> 1.1'
  spec.add_runtime_dependency 'lolcat', '~> 100.0', '>= 100.0.1'
end

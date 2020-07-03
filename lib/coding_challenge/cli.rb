# frozen_string_literal: true

require 'thor'

module CodingChallenge
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'coding_challenge version'
    def version
      require_relative 'version'
      puts "v#{CodingChallenge::VERSION}"
    end
    map %w[--version -v] => :version

    desc 'start', 'Runs the app!'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    method_option :skip_intro_animation, type: :boolean,
                                         desc: 'Skips intro animation'
    def start(*)
      if options[:help]
        invoke :help, ['start']
      else
        require_relative 'commands/start'
        CodingChallenge::Commands::Start.new(options).execute
      end
    end
  end
end

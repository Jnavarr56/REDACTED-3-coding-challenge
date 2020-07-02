# frozen_string_literal: true

require_relative '../command'

module CodingChallenge
  module Commands
    class Start < CodingChallenge::Command
      def initialize(options)
        @options = options
      end
    
      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...

        self.greet()
        output.puts "OK"
      end

      private
      def greet()

        puts "'Hey TeePublic hiring crew!'"
        # prompt = TTY::Prompt.new
        # prompt.ask('Hey TeePublic hiring crew!')
        
        
      end
    end
  end
end

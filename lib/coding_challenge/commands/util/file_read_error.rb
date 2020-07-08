# frozen_string_literal: true

class FileReadError < StandardError
  def initialize(source_uri)
    super("Could not read file from #{source_uri}!")
  end
end

# frozen_string_literal: true

class InvalidOptionError < StandardError
  def initialize(product_type, option_type, option_argument)
    super("Product of type #{product_type.upcase} and #{option_type.upcase} option type of value #{option_argument.upcase} not in catalog!")
  end
end

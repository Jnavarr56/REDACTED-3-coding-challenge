# frozen_string_literal: true

class InvalidProductTypeError < StandardError
  def initialize(product_type)
    super("Product of type #{product_type.upcase} not in catalog!")
  end
end

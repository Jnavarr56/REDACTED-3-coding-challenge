# frozen_string_literal: true

require_relative './invalid_product_type_error'
require_relative './invalid_option_error'
require_relative './file_read_error'

require 'net/http'
require 'json'
require 'date'

class Inventory
  @@DEFAULT_PRODUCTS_LIST_URL = 'https://gist.githubusercontent.com/michaelporter/b2743e0cdad0664fa9517c0a6b82cdda/raw/67e4606007391f678c9330ee3a77a9024fce4e64/products.json'
  attr_reader :source_type, :source_uri, :products_list
  def initialize
    @source_type = nil
    @source_uri = nil
    @products_list = nil
    @products_schema = nil
  end

  def handle_query(query)
    product_options_schema = @products_schema[query.product_type.downcase]
    is_invalid_product_type = product_options_schema.nil?
    raise InvalidProductTypeError, query.product_type if is_invalid_product_type

    results = []
    product_options_schema.each_with_index do |(option_type, option_values_map), arg_position|
      option_argument = query.options[arg_position]
      is_argument_provided = !option_argument.nil?

      if is_argument_provided
        is_invalid_argument = !option_values_map.key?(option_argument)
        raise InvalidOptionError.new(query.product_type, option_type, option_argument) if is_invalid_argument
      else
        possible_option_values = option_values_map.keys
        results << "#{option_type.capitalize}: #{possible_option_values.join(', ')}"
      end
    end

    query.results = results
    query
  end

  def load_products_list_from_source(source_type, source_uri)
    begin
      products_list = load_from_file_path(source_uri) if source_type == 'FILE PATH'
      products_list = load_from_file_url(source_uri) if source_type == 'URL'
      raise StandardError if products_list.nil?
    rescue StandardError
      raise FileReadError, source_uri
    end
    set_as_data_source(source_type, source_uri, products_list)
  end

  def load_products_list_from_default
    begin
      products_list = load_from_file_url(@@DEFAULT_PRODUCTS_LIST_URL)
      raise StandardError if products_list.nil?
    rescue StandardError
      raise FileReadError, source_uri
    end
    set_as_data_source('DEFAULT', @@DEFAULT_PRODUCTS_LIST_URL, products_list)
  end

  private

  def index_product_schema(products_list)
    products_schema = {}
    products_list.each do |p|
      if !products_schema.key?(p['product_type'])
        products_schema[p['product_type']] = p['options'].transform_values { |o| Hash[o, true] }
      else
        products_schema[p['product_type']].merge!(p['options']) { |_, o, n| o.merge(Hash[n, true]) }
      end
    end
    products_schema
  end

  def set_as_data_source(source_type, source_uri, products_list)
    @products_list = products_list
    @products_schema = index_product_schema(products_list)
    @source_type = source_type
    @source_uri = source_uri
  end

  def load_from_file_path(file_path)
    products_list_file = File.open(file_path)
    products_list_file_content = products_list_file.read
    products_list_hash = JSON.parse(products_list_file_content)
    products_list_hash
  end

  def load_from_file_url(url)
    request_uri = URI(url)
    request_response = Net::HTTP.get_response(request_uri)
    request_response_content = request_response.body
    products_list_hash = JSON.parse(request_response_content)
    products_list_hash
  end
end

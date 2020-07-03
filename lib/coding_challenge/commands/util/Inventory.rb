# frozen_string_literal: true

require 'net/http'
require 'json'

class Inventory
  @@DEFAULT_PRODUCTS_LIST_URL = 'https://gist.githubusercontent.com/michaelporter/b2743e0cdad0664fa9517c0a6b82cdda/raw/67e4606007391f678c9330ee3a77a9024fce4e64/products.json'
  attr_reader :source_type, :source_uri, :products_list
  def initialize
    @source_type = nil
    @source_uri = nil
    @products_list = nil
  end

  def handle_query(query)
    remaining_props_seen = {}
    remaining_props = []

    @products_list.each do |product|
      next if product['product_type'] != query.product_type

      search_start = query.options.length
      option_types = product['options'].keys

      (search_start..option_types.length - 1).each do |i|
        option_type = option_types[i]
        option_value = product['options'][option_type]

        if remaining_props_seen[option_type].nil?
          remaining_props_seen[option_type] = {}
          remaining_props_seen[option_type][option_value] = true
          remaining_props.push("#{option_type.capitalize}: #{option_value}")
        elsif !remaining_props_seen[option_type][option_value]
          remaining_props_seen[option_type][option_value] = true
          remaining_props[i - search_start] += ", #{option_value}"
        end
      end
    end

    query.performed_at = DateTime.now
    query.results = remaining_props

    query
  end

  def load_products_list_from_source(source_type, source_uri)
    if source_type == 'FILE PATH'
      load_from_file_path(source_uri)
    elsif source_type == 'URL'
      load_from_file_url(source_uri)
    end

    unless @products_list.nil?
      @source_type = source_type
      @source_uri = source_uri
    end

    @products_list
  end

  def load_products_list_from_default
    load_from_file_url(@@DEFAULT_PRODUCTS_LIST_URL)

    unless @products_list.nil?
      @source_type = 'DEFAULT'
      @source_uri = @@DEFAULT_PRODUCTS_LIST_URL
    end

    @products_list
  end

  private

  def load_from_file_path(file_path)
    products_list_file = File.open(file_path)
    products_list_file_content = products_list_file.read
    products_list_hash = JSON.parse(products_list_file_content)

    @products_list = products_list_hash
  rescue StandardError
    @products_list = nil
  end

  def load_from_file_url(url)
    request_uri = URI(url)
    begin
      request_response = Net::HTTP.get_response(request_uri)
      request_response_content = request_response.body
      products_list_hash = JSON.parse(request_response_content)

      @products_list = products_list_hash
    rescue StandardError
      @products_list = nil
    end
  end
end

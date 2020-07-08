# frozen_string_literal: true

require_relative '../lib/coding_challenge/commands/util/inventory'
require_relative '../lib/coding_challenge/commands/util/1uery'

RSpec.describe CodingChallenge do
  it 'properly loads a product list from a json file at a URL' do
    new_inventory = Inventory.new
    new_inventory.load_products_list_from_source('URL', 'https://gist.githubusercontent.com/michaelporter/b2743e0cdad0664fa9517c0a6b82cdda/raw/67e4606007391f678c9330ee3a77a9024fce4e64/products.json')
    expect(new_inventory.products_list).to be_an(Array)
  end

  it 'properly loads a product list from a json file at a file path' do
    new_inventory = Inventory.new
    new_inventory.load_products_list_from_source('FILE PATH', "#{__dir__}/test_data.json")
    expect(new_inventory.products_list).to be_an(Array)
  end

  it 'properly executes a query with no options' do
    new_inventory = Inventory.new
    new_inventory.load_products_list_from_default
    new_query = Query.new(['tshirt'])
    query_with_results = new_inventory.handle_query(new_query)

    expect(query_with_results.results).to be_an(Array)
  end

  it 'properly executes a query with one option' do
    new_inventory = Inventory.new
    new_inventory.load_products_list_from_default
    new_query = Query.new(%w[tshirt male])
    query_with_results = new_inventory.handle_query(new_query)

    expect(query_with_results.results).to be_an(Array)
  end

  it 'properly executes a query with three options' do
    new_inventory = Inventory.new
    new_inventory.load_products_list_from_source('URL', 'https://gist.githubusercontent.com/michaelporter/b2743e0cdad0664fa9517c0a6b82cdda/raw/67e4606007391f678c9330ee3a77a9024fce4e64/products.json')
    new_query = Query.new(%w[tshirt male black])
    query_with_results = new_inventory.handle_query(new_query)

    expect(query_with_results.results).to be_an(Array)
  end
end

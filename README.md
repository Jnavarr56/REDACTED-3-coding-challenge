# CodingChallenge

Had fun with this. I published it as gem here: https://rubygems.org/gems/coding_challenge.

## Quickstart

`gem install coding_challenge` then
`coding_challenge start`

## Screenshots

1. using CLI menu to input arguements
   ![gif1](./gif1.gif)
2. inputting arguments directly from commandline
   ![gif2](./gif2.gif)

## Installation

1. via cloning

Clone repo. Then in project directory `bundle install`.

2. via rubygems

`gem install coding_challenge`

## Usage

To run with a cool CLI UI at the start, either do:

- (IF CLONED) Go to project directory and: `./exe/coding_challenge start [product type] [options]`
- (IF INSTALLED AS GEM) from CLI do: `coding_challenge start [product type] [options]`

To run without a cool CLI UI at the start but have it appear after, either do:

- (IF CLONED) Go to project directory and: `./exe/coding_challenge start [product type] [options] --skip_intro_animation=true`
- (IF INSTALLED AS GEM) from CLI do: `coding_challenge start [product type] [options] --skip_intro_animation=true`

## Testing

Clone and go to project directory and do `rspec spec`

## Code Explanation

Since the product list is represented as an array, there is NO
way to solve this problem in O(1) time.

At the very least, any solution is going to require 1 full iteration through the product list.
What we can do, is create a hash based schema that will group all of the product types, option types,
and option values as keys in a logical hierachy so that afterwards, detecting the prescence of data can be done
simply by attempting to access it from the hash as a key O(1) time.

I tried to do this compactly/elegantly by creating the following method and having it execute
immediately after reading the products list:

```
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
```

The above operation going to require one loop through the product list and then for each item,
a nested loop that runs for the number of option types that exist for that item.

The generated products schema would look like this:

`{"tshirt"=>{"gender"=>{"male"=>true, "female"=>true}, "color"=>{"red"=>true, "green"=>true, "navy"=>true, "white"=>true, "black"=>true}, "size"=>{"small"=>true, "medium"=>true, "large"=>true, "extra-large"=>true, "2x-large"=>true}}, "mug"=>{"type"=>{"coffee-mug"=>true, "travel-mug"=>true}}, "sticker"=>{"size"=>{"x-small"=>true, "small"=>true, "medium"=>true, "large"=>true, "x-large"=>true}, "style"=>{"matte"=>true, "glossy"=>true}}}`

Run Time ~> sum of O(num_option_types<sub>i<sub>) where i goes from 1 to the length of the products_list array

Next, the following method below will execute using the product_schema produced by `index_product_schema`.

You can see that validating the precesence of/accessing the options schema for a particular
product type is done in O(1) in the first line.

In an option schema for a given product type, the keys are option types and the values are hashes that contain keys
every possible option value for a given option type. ex for sticker:
`{"size"=>{"x-small"=>true, "small"=>true, "medium"=>true, "large"=>true, "x-large"=>true}, "style"=>{"matte"=>true, "glossy"=>true}}`
We can now iterate through all of the option types/option values pairs using an index value (arg_position) to keep
track of our position in the hash.

Validating an options argument against possible option values is done using the index to match up
the CLI argument at the position of the index to the current option types/option values pair. We do this in O(1)
time by seeing if the argument exists as a key in the option values pair.

The current option values hash is transformed into a friendly string by joining the keys
together with commas.

The main loop will execute for the number of option types for a given product type regardless of the
size of the cli arguments input, which is a respective constant for each product type, so it is there for O(1).

```
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


I created an Inventory class to act as a wrapper around a product list. When we load a product list,
This an instance of this class is then passed to an instance of a class I made in lib/coding_challenge/commands/util/Inventory.rb as an arg to this method:

```

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

```

This is the main query algorithm.

A cool thing you can do is specify for the Inventory class to load in a product list in a JSON file from a URL or alternate file path. You can do this from the CLI menu.
This method invokes some private methods I created for handling the cases but the logic is captured here:

```

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

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/coding_challenge. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/coding_challenge/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the CodingChallenge project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/coding_challenge/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2020 Jorge Navarro. See [MIT License](LICENSE.txt) for further details.

```

```

```

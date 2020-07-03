# CodingChallenge

Had fun with this. I published it as gem here: https://rubygems.org/gems/coding_challenge.

## Quickstart

`gem install coding_challenge`
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

``gem install coding_challenge```

## Usage

To run with a cool CLI UI at the start, either do:

- (IF CLONED) Go to project directory and: `./exe/coding_challenge start [product type] [options]`
- (IF INSTALLED AS GEM) from CLI do: `coding_challenge start [product type] [options]`

To run without a cool CLI UI at the start but have it appear after, either do:
_ (IF CLONED) Go to project directory and: `./exe/coding_challenge start [product type] [options] --skip_intro_animation=true`
_ (IF INSTALLED AS GEM) from CLI do: `coding_challenge start [product type] [options] --skip_intro_animation=true`

## Testing

Clone and go to project directory and do `rspec spec`

## Code Highlight

I use an object to group together the query args and results like so

```
class Query
  attr_reader :product_type, :options, :results
  attr_writer :performed_at, :results

  def initialize(query_args)
    @product_type = query_args[0]
    @options = query_args.slice(1, query_args.length)
    @performed_at = nil
    @results = nil
  end

  def formatted_results
    results_str = "Performed At #{@performed_at}\n"
    results_str +=  "   Product Type Arg: #{@product_type}\n"
    results_str +=  "   Options Args: #{@options.join(', ')}\n"
    results_str +=  "   Results:\n"
    results_str +=  "      #{@results.join("\n      ")}"

    results_str
  end
end
```

This an instance of this class is then passed to an instance of a class I made in lib/coding_challenge/commands/util/Inventory.rb as an arg to this method

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

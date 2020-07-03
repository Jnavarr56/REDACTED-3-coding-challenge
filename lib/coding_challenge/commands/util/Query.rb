# frozen_string_literal: true

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

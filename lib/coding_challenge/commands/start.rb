# frozen_string_literal: true

require_relative '../command'
require_relative './util/Inventory'
require_relative './util/Query'
require_relative './util/animation'

require 'tty-spinner'
require 'colorize'

module CodingChallenge
  module Commands
    class Start < CodingChallenge::Command
      include Animation

      @@BASE_NAVIGATION_STATES = %w[HOME_MENU SET_INVENTORY_FILE INIT_QUERY VIEW_QUERIES EXITED]
      @@DEFAULT_PRODUCTS_LIST_URL = 'https://gist.githubusercontent.com/michaelporter/b2743e0cdad0664fa9517c0a6b82cdda/raw/67e4606007391f678c9330ee3a77a9024fce4e64/products.json'

      def initialize(options)
        @options = options
        @inventory = nil
        @base_navigation_state_index = 0
        @prev_base_navigation_state_index = nil
        @queries = []
      end

      def execute(input: $stdin, output: $stdout)
        cli_args = ARGV.slice(1, ARGV.length)

        perform_intro_animation if @options['skip_animation'].nil?

        if cli_args.empty?
          loading_animation('Loading menu...', 1)
        else
          loading_animation('Calculating results...', 2)

          new_inventory = Inventory.new
          new_inventory.load_products_list_from_default
          @inventory = new_inventory

          new_query = Query.new(cli_args)
          query_with_results = @inventory.handle_query(new_query)

          puts 'Results:'.colorize(:yellow)
          puts query_with_results.results

          @queries.push(query_with_results.formatted_results)
        end

        exited = false
        until exited
          base_navigation_state = @@BASE_NAVIGATION_STATES[@base_navigation_state_index]

          if base_navigation_state == 'HOME_MENU'
            new_base_navigation_state_index = execute_home_menu
          elsif base_navigation_state == 'SET_INVENTORY_FILE'
            new_base_navigation_state_index = execute_set_inventory_file
          elsif base_navigation_state == 'INIT_QUERY'
            new_base_navigation_state_index = execute_init_query
          elsif base_navigation_state == 'VIEW_QUERIES'
            new_base_navigation_state_index = execute_view_queries
          elsif base_navigation_state == 'EXITED'
            exited = true
          end

          if new_base_navigation_state_index == 'BACK'
            @base_navigation_state_index = @prev_base_navigation_state_index
          elsif @base_navigation_state_index != @prev_base_navigation_state
            @prev_base_navigation_state_index = @base_navigation_state_index
            @base_navigation_state_index = new_base_navigation_state_index
          end
        end

        exit(0)
      end

      private

      def perform_intro_animation
        intro_loading_bars_animation
        puts "\n"
        intro_title_animation
        puts "\n"
      end

      def execute_home_menu
        menu_prompt = prompt(active_color: :cyan, symbols: { marker: '>' })
        menu_prompt.select("\n\nHome Menu:") do |menu|
          menu.choice 'set product list file path', 1
          menu.choice 'query the product list', 2
          menu.choice 'view past query results', 3
          menu.choice 'exit', 4
        end
      end

      def execute_set_inventory_file
        intro_text =
          if @inventory.nil?
            "I don't currently have a product list loaded so I'll need to load one in from a valid JSON file."
          else
            "The current product list has been loaded from the file at: #{@inventory.source_uri}"
          end

        type_effect(intro_text)
        main_menu_prompt = prompt(active_color: :cyan, symbols: { marker: '>' })
        main_menu_action_index = main_menu_prompt.select("\n\nWhat would you like to do?:") do |menu|
          menu.choice 'set product list file from a path', 0
          menu.choice 'set product list file from a url', 1
          menu.choice 'set product list file from the default file', 2
          menu.choice 'go back', 'BACK'
        end

        return 'BACK' if main_menu_action_index == 'BACK'

        new_inventory = Inventory.new

        if main_menu_action_index == 0
          done = false
          until done
            new_filepath = prompt.ask('Please enter the absolute path to the JSON file (or QUIT to cancel): ')
            if new_filepath == 'QUIT'
              done = true
            else
              loading_animation('Checking file readability...', 2)
              begin
                new_inventory.load_products_list_from_source('FILE PATH', new_filepath)

                raise StandardError if new_inventory.products_list.nil?

                @inventory = new_inventory
                prompt.say("\nFile loaded successfully!")
                done = true
              rescue StandardError
                prompt.say('Could not read this file!')
              end
            end
          end
        elsif main_menu_action_index == 1
          done = false
          until done
            new_file_url = prompt.ask('Please enter the URL to the JSON file (or QUIT to cancel): ')
            if new_file_url == 'QUIT'
              done = true
            else
              spinner = TTY::Spinner.new("[:spinner] fetching file from #{new_file_url}", format: :pulse_2, clear: true)
              spinner.auto_spin
              begin
                new_inventory.load_products_list_from_source('URL', new_file_url)
                raise StandardError if new_inventory.products_list.nil?

                @inventory = new_inventory
                prompt.say("\nFile fetched successfully!")
                done = true
              rescue StandardError
                prompt.say('Could not fetch this file!')
              end
              spinner.stop
            end

          end
        elsif main_menu_action_index == 2
          spinner = TTY::Spinner.new('[:spinner] fetching default file from url', format: :pulse_2, clear: true)
          spinner.auto_spin
          begin
            new_inventory.load_products_list_from_default
            raise StandardError if new_inventory.products_list.nil?

            @inventory = new_inventory
            prompt.say("\nDefault file fetched successfully!")
          rescue StandardError
            prompt.say('Could not fetch the default file!')
          end
          spinner.stop
        end
        execute_set_inventory_file
      end

      def execute_init_query
        if @inventory.nil?
          puts 'Inventory was never loaded! Redirection to product list config menu.'.colorize(:red)
          return 1
        end
        args = []

        puts ''
        puts ''
        type_effect("First, I'll need the first query argument. This is where you specify the product line.")
        product_type_arg = read_product_type_arg
        return 0 if product_type_arg == 'QUIT'

        args.push(product_type_arg)
        puts "Product Type: #{product_type_arg}".upcase.colorize(:light_blue)
        puts ''

        type_effect("Next, I'll need the the options query arguments. This is where you specify the product options.")
        options_args = read_options_args
        return 0 if options_args == 'QUIT'

        args += options_args
        puts "Options: #{options_args}".upcase.colorize(:light_blue)
        puts ''
        puts ''

        new_query = Query.new(args)
        query_with_results = @inventory.handle_query(new_query)
        loading_animation('Calculating...', 2)
        puts 'Results:'.colorize(:yellow)
        puts query_with_results.results
        @queries.push(query_with_results.formatted_results)

        0
      end

      def read_product_type_arg
        loop do
          arg_input = prompt.ask('Please enter product type argument for this query (or QUIT to cancel): ')
          return arg_input unless arg_input.empty?
        end
      end

      def read_options_args
        options_args = []
        loop do
          arg_input = prompt.ask('Please enter an option argument for this query (or QUIT to cancel, NONE for no arguments, DONE when you are finished): ')

          return 'QUIT' if arg_input == 'QUIT'
          return [] if arg_input == 'NONE'
          return options_args if arg_input == 'DONE'

          options_args.push(arg_input) unless arg_input.empty?
        end
      end

      def execute_view_queries
        if @queries.empty?
          type_effect("You haven't performed any queries yet!")
        else
          puts @queries
        end

        0
      end
    end
  end
end

# frozen_string_literal: true

module Hyperion
  # Main navigation for the application
  class Navigator
    def initialize(initial_route, options, view)
      @stack = [initial_route]
      @options = options
      @view = view
    end

    def run
      while @stack.any?
        route = @stack.last

        # Instantiate the menu using the factory
        menu = MenuFactory.build(route, @options, @view)

        # All menus now respond to instance method .show
        result = menu.show

        # Ensure result is a hash and has an action
        result = { action: :exit } unless result.is_a?(Hash)

        case result[:action]
        when :push
          @stack.push(result[:target])
        when :back
          @stack.pop
        when :exit
          @stack.clear
        else
          @stack.clear
        end
      end
    end
  end
end

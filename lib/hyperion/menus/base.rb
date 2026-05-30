# frozen_string_literal: true

module Menus
  # Base level class to support othe menus
  class Base
    def initialize(options:, view:)
      @options = options
      @view = view
    end

    def show
      prompts = @options.map { |item| item[:prompt] }
      selected = @view.select(items: prompts, prompt: 'Choose an option')

      return { action: :back } if selected.nil?

      handle_selection(selected)
    end

    protected

    def find_option(selected)
      @options.find { |item| item[:prompt] == selected }
    end

    def handle_selection(_selected)
      raise NotImplementedError, "#{self.class} must implement handle_selection"
    end
  end
end

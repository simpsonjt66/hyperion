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

    private

    def handle_selection(selected)
      # To be implemented by subclasses
      { action: :exit }
    end
  end
end

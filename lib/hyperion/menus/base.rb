# frozen_string_literal: true

module Menus
  # Base level class to support othe menus
  class Base
    def initialize(options:, ui:)
      @options = options
      @ui = ui
    end

    def show
      prompts = options.map { |item| item[:prompt] }
    end
  end
end

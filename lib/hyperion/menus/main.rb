# frozen_string_literal: true

module Menus
  # Main menu class
  class Main < Base
    def handle_selection(selected)
      target = find_option(selected)&.dig(:command).to_s.downcase.to_sym
      { action: :push, target: target }
    end
  end
end

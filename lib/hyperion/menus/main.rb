# frozen_string_literal: true

module Menus
  # Main menu class
  class Main
    def self.show
      menu_options = OPTIONS[:main_menu]
      prompts = menu_options.map { |item| item[:name] }
      selected = Utilities.rofi_select(items: prompts)

      return { action: :exit } if selected.nil?

      launch_command = menu_options.find { |item| item[:name] == selected }&.dig(:command).to_s.capitalize
      target = Menus.const_get(launch_command)
      { action: :push, target: target }
    end
  end
end

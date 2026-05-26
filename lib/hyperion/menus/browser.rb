# frozen_string_literal: true

module Menus
  # Set the default terminal
  class Browser
    def self.show
      menu_options = OPTIONS[:default_browser_menu]
      prompts = menu_options.map { |item| item[:prompt] }
      selected = Utilities.rofi_select(items: prompts)

      return { action: :back } if selected.nil?

      launch_command = menu_options.find { |item| item[:prompt] == selected }&.dig(:command)
      system(launch_command)
      { action: :exit }
    end
  end
end

# frozen_string_literal: true

module Menus
  # Package maintenance menu.
  class Package
    def self.show
      menu_options = OPTIONS[:package_menu]
      prompts = menu_options.map { |item| item[:prompt] }
      selected = Utilities.rofi_select(items: prompts)

      return { action: :back } if selected.nil?

      launch_command = menu_options.find { |item| item[:prompt] == selected }&.dig(:command).to_s
      system('xdg-terminal-exec', '--app-id=org.hyperion.terminal', launch_command)
      { action: :exit }
    end
  end
end

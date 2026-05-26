# frozen_string_literal: true

module Menus
  # Launches the config menu to edit most used config files
  class Config
    def self.show
      menu_options = OPTIONS[:config_menu]
      prompts = menu_options.map { |item| item[:prompt] }
      selected = Utilities.rofi_select(items: prompts)

      return { action: :back } if selected.nil?

      filepath = menu_options.find { |item| item[:prompt] == selected }&.dig(:command)

      expanded = File.expand_path("#{ENV['XDG_CONFIG_HOME']}/" + filepath)
      system('notify-send', "Editing config file #{expanded}")
      system('launch-editor', expanded)
      { action: :exit }
    end
  end
end

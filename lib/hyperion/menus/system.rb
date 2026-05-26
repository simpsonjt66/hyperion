# frozen_string_literal: true

module Menus
  # Shows the system menu with various power options
  class System
    def self.show
      menu_options = OPTIONS[:system_menu]
      prompts = menu_options.map { |item| item[:prompt] }
      selected = Utilities.rofi_select(items: prompts)

      return { action: :back } if selected.nil?

      option = menu_options.find { |item| item[:prompt] == selected }
      system(option[:command]) if option[:confirm].nil? || Utilities.confirm_dialog(option[:confirm])
      { action: :exit }
    end
  end
end

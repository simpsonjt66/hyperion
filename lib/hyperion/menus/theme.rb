# frozen_string_literal: true

module Menus
  # Menu to list and select current themes
  class Theme
    def self.show
      selected = Utilities.rofi_select(**menu_options)

      return { action: :back } if selected.nil?

      system('notify-send', "Theme set to #{selected}")
      Utilities::ThemeSet.call(theme_list[selected])
      { action: :exit }
    end

    class << self
      private

      def theme_list
        Utilities::ThemeList.get
      end

      def current_theme
        Utilities::ThemeCurrent.get
      end

      def default_selection
        current_theme && theme_list.key(current_theme) || nil
      end

      def menu_options
        {
          items: theme_list.keys,
          current: default_selection,
          prompt: 'Select'
        }
      end
    end
  end
end

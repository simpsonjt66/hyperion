# frozen_string_literal: true

module Menus
  # Shows a list of installed fonts, with the current font highlighted
  class Font < Base
    def initialize(options:, view:, font_manager: Utilities::FontManager.new)
      super(options: options, view: view)
      @font_manager = font_manager
    end

    def show
      menu_options = @font_manager.terminal_font_list
      current_font = @font_manager.current_font
      selected = @view.select(items: menu_options, current: current_font)

      return { action: :back } if selected.nil?

      @font_manager.update_fonts(selected)
      { action: :exit }
    end
  end
end

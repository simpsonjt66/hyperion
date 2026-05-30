# frozen_string_literal: true

module Menus
  # Shows a list of installed fonts, with the current font highlighted
  class Font < Base
    def show
      # TODO: Extract this logic out to a utility class.
      menu_options = Open3.capture3('font-list')[0].lines.map(&:chomp)
      current_font = Open3.capture3('font-current')[0].strip
      selected = @view.select(items: menu_options, current: current_font)

      return { action: :back } if selected.nil?

      @view.execute('font-set', selected) if selected
      { action: :exit }
    end
  end
end

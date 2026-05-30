# frozen_string_literal: true

module Menus
  # Shows the system menu with various power options
  class System < Base
    def handle_selection(selected)
      option = find_option(selected)
      @view.execute(option[:command]) if option[:confirm].nil? || @view.confirm(option[:confirm])
      { action: :exit }
    end
  end
end

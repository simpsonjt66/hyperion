# frozen_string_literal: true

module Menus
  # Shows rofi in drun mode as an app launcher
  class Apps < Base
    def show
      @view.drun
      { action: :back }
    end
  end
end

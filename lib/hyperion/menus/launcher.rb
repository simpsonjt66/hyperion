# frozen_string_literal: true

module Menus
  # Parent class to handle default setting.
  class Launcher < Base
    def handle_selection(selected)
      launch_command = find_option(selected)&.dig(:command)
      @view.execute(launch_command)
      { action: :exit }
    end
  end
end

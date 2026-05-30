# frozen_string_literal: true

module Menus
  # Set the default terminal
  class Terminal < Base
    def handle_selection(selected)
      launch_command = find_option(selected)&.dig(:command)
      @view.execute(launch_command)
      { action: :exit }
    end
  end
end

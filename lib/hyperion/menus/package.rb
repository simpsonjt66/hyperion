# frozen_string_literal: true

module Menus
  # Package maintenance menu.
  class Package < Base
    def handle_selection(selected)
      launch_command = find_option(selected)&.dig(:command).to_s
      @view.execute('xdg-terminal-exec', '--app-id=org.hyperion.terminal', launch_command)
      { action: :exit }
    end
  end
end

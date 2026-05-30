# frozen_string_literal: true

module Menus
  # Launches the config menu to edit most used config files
  class Config < Base
    def handle_selection(selected)
      filepath = find_option(selected)&.dig(:command)

      expanded = File.expand_path("#{ENV['XDG_CONFIG_HOME']}/" + filepath)
      @view.notify("Editing config file #{expanded}")
      @view.execute('launch-editor', expanded)
      { action: :exit }
    end
  end
end

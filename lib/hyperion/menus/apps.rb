# frozen_string_literal: true

module Menus
  # Shows rofi in drun mode as an app launcher
  class Apps
    def self.show
      app_launcher = 'uwsm-app -- {cmd}'
      system('rofi', '-show',
             'drun',
             '-run-command', app_launcher,
             '-theme', '~/.config/rofi/themes/app-launcher.rasi')
      { action: :back }
    end
  end
end

# frozen_string_literal: true

module Hyperion
  module View
    # Adapter for rofi as system menu generator
    class RofiAdapter
      def initialize(config = {})
        @config = config
      end

      def select(items:, prompt: 'Select', current: nil)
        Utilities.rofi_select(
          items: items,
          prompt: prompt,
          current: current
        )
      end

      def drun
        system('rofi', '-show',
               'drun',
               '-run-command', launcher,
               '-theme', '~/.config/rofi/themes/app-launcher.rasi')
      end

      def launcher
        'uwsm-app -- {cmd}'
      end

      def confirm(message)
        Utilities.confirm_dialog(message)
      end

      def notify(message)
        system('notify-send', message)
      end
    end
  end
end

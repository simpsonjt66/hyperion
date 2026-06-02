# frozen_string_literal: true

module Hyperion
  module View
    # Adapter for rofi as system menu generator
    class RofiAdapter
      def initialize(config = {})
        @config = config
      end

      def select(items:, prompt: 'Select', current: nil)
        current_index = items.index(current) || 0

        result = IO.popen(select_command(items, current_index, prompt), 'r+') do |io|
          io.puts items
          io.close_write
          io.read.chomp
        end

        $CHILD_STATUS.success? && !result.empty? ? result : nil
      end

      def select_command(items, current_index, prompt)
        longest = items.max_by(&:length)&.length || 0

        [
          'rofi',
          '-dmenu',
          '-p', prompt,
          '-selected-row', current_index.to_s,
          '-i', '-l', items.size.to_s,
          '-theme', '~/.config/rofi/themes/system-menu.rasi',
          '-theme-str', "window { width: #{longest}em;}"
        ]
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
        system('confirm-dialog', '-m', message)
      end

      def notify(message)
        system('notify-send', message)
      end

      def execute(command, *args)
        system(command, *args)
      end
    end
  end
end

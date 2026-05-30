# frozen_string_literal: true

module Hyperion
  module View
    class RofiAdapter
      def initialize(config = {})
        @config = config
      end

      # Standard interface used by all menus
      def select(items:, prompt: 'Select', current: nil)
        # Delegating to existing logic in Utilities
        Utilities.rofi_select(
          items: items,
          prompt: prompt,
          current: current
        )
      end

      def confirm(message)
        Utilities.confirm_dialog(message)
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

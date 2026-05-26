# frozen_string_literal: true

module Utilities
  # Restart applications on theme changes
  class Restart
    def self.kitty
      return unless get_pid('kitty')

      system('killall -SIGUSR1 kitty')
    end

    def self.waybar
      system('pkill -9 -x waybar')
      system('setsid uwsm-app -- waybar')
    end

    def self.get_pid(process_name)
      pid = `pgrep -x #{process_name}`.strip
      pid.empty? ? nil : pid.to_i
    end
  end
end

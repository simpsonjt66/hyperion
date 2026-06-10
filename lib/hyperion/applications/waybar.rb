# frozen_string_literal: true

require_relative 'base'

module Applications
  # Manages functionality for Waybar
  class Waybar < Base
    def name
      'waybar'
    end

    def reload_config
      system("killall -SIGUSR2 #{name}")
    end
  end
end

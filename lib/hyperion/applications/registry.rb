# frozen_string_literal: true

require_relative 'waybar'
require_relative 'hypridle'

module Applications
  # External applications management
  class Registry
    def initialize; end

    def all
      [Waybar.new, Hypridle.new]
    end
  end
end

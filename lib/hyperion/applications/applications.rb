# frozen_string_literal: true

module Applications
  # External applications management
  class Applications
    def initialize; end

    def all
      [Waybar.new, Hypridle.new]
    end
  end
end

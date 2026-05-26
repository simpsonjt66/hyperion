# frozen_string_literal: true

module Utilities
  # Parses the data from alacritty config file
  class AlacrittyConfig
    def initialize(toml_data)
      @colors = toml_data.fetch(:colors, {})
    end

    COLOR_NAMES = %i[black red green yellow blue magenta cyan white].freeze

    def normal_colors
      COLOR_NAMES.map { |name| @colors.dig(:normal, name) }
    end

    def bright_colors
      COLOR_NAMES.map { |name| @colors.dig(:bright, name) }
    end

    def all_colors
      normal_colors + bright_colors
    end

    def indexed_colors
      all_colors.map.with_index do |color, i|
        ["color#{i}", color]
      end.to_h
    end

    def background
      @colors.dig(:primary, :background) || normal_colors[0]
    end

    def foreground
      @colors.dig(:primary, :foreground) || normal_colors[7]
    end

    def to_h
      {
        'accent' => normal_colors[4],
        'cursor' => foreground,
        'foreground' => foreground,
        'background' => background,
        'selection_foreground' => background,
        'selection_background' => foreground
      }.merge(indexed_colors)
    end
  end
end

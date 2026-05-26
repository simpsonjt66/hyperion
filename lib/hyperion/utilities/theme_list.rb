# frozen_string_literal: true

module Utilities
  # Returns a list of theme folders and human readable options
  class ThemeList
    def self.get
      themes.each_with_object({}) do |d, h|
        h[d.split('-').map(&:capitalize).join(' ')] = d
      end
    end

    class << self
      private

      def theme_directories
        File.join(THEME_PATH, '/*/')
      end

      def themes
        Dir.glob(theme_directories).map { |d| File.basename(d) }
      end
    end
  end
end

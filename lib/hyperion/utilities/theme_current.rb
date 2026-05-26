# frozen_string_literal: true

module Utilities
  # Returns the current theme
  class ThemeCurrent
    def self.get
      return unless File.exist?(current_theme_file)

      File.read(File.join(current_theme_file)).chomp
    end

    class << self
      private

      def current_theme_file
        current_path = File.join(HYPERION_PATH, 'current')
        File.join(current_path, 'theme.current')
      end
    end
  end
end

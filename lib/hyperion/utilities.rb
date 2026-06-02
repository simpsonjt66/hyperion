# frozen_string_literal: true

# Utility functions for app launcher
module Utilities
  data_path = ENV['XDG_DATA_HOME'] || File.join(Dir.home, '.local', 'share')

  HYPERION_PATH = File.join(data_path, 'hyperion')
  THEME_PATH = File.join(HYPERION_PATH, 'themes')
  CURRENT_THEME_PATH = File.join(HYPERION_PATH, 'current', 'theme')
end

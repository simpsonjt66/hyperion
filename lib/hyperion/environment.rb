# frozen_string_literal: true

module Utilities
  DATA_PATH = ENV['XDG_DATA_HOME'] || File.join(Dir.home, '.local', 'share')
  HYPERION_PATH = File.join(DATA_PATH, 'hyperion')
  THEME_PATH = File.join(HYPERION_PATH, 'themes')
  CURRENT_THEME_PATH = File.join(HYPERION_PATH, 'current', 'theme')
  NEXT_THEME_PATH = File.join(HYPERION_PATH, 'next_theme')
  TEMPLATES_PATH = File.join(HYPERION_PATH, 'templates')
  CONFIG_PATH = ENV['XDG_CONFIG_HOME'] || File.join(Dir.home, '.config')
end

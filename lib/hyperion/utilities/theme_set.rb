# frozen_string_literal: true

module Utilities
  # Set's the current system theme
  class ThemeSet
    NEXT_THEME_PATH = File.join(HYPERION_PATH, 'next_theme')

    def self.call(new_current_theme)
      new_theme_path = File.join(THEME_PATH, new_current_theme)
      new_theme_files = File.join(new_theme_path, '/.')
      apply_theme(new_current_theme, new_theme_files)
      Restart.kitty
      Restart.waybar
    end
    class << self
      private

      def remove_current_theme_dir
        FileUtils.rm_rf(CURRENT_THEME_PATH)
      end

      def recreate_next_theme_dir
        FileUtils.rm_rf(NEXT_THEME_PATH) if File.exist?(NEXT_THEME_PATH)
        FileUtils.mkdir_p(NEXT_THEME_PATH)
      end

      def move_next_to_current
        FileUtils.mv(NEXT_THEME_PATH, CURRENT_THEME_PATH)
      end

      def apply_theme(new_current_theme, new_theme_files)
        recreate_next_theme_dir
        copy_theme_files(new_theme_files)

        unless File.exist?(File.join(NEXT_THEME_PATH, 'colors.toml'))
          ColorFileFromAlacritty.new(NEXT_THEME_PATH).extract
        end

        ThemeSetTemplate.new(NEXT_THEME_PATH).build_config_files

        remove_current_theme_dir
        move_next_to_current
        write_theme_marker(new_current_theme)
      end

      def write_theme_marker(new_current_theme)
        current_path = File.join(HYPERION_PATH, 'current')
        File.write(File.join(current_path, 'theme.current'), new_current_theme)
      end

      def copy_theme_files(new_theme_files)
        FileUtils.cp_r(new_theme_files, NEXT_THEME_PATH)
      end
    end
  end
end

# frozen_string_literal: true

module Utilities
  # Manages theme discovery and current state persistence
  class ThemeRepository
    attr_reader :theme_path

    def initialize(theme_path: THEME_PATH, hyperion_path: HYPERION_PATH)
      @theme_path = theme_path
      @hyperion_path = hyperion_path
    end

    def all
      themes.each_with_object({}) do |d, h|
        h[d.split('-').map(&:capitalize).join(' ')] = d
      end
    end

    def current
      return unless File.exist?(current_theme_file)

      File.read(current_theme_file).chomp
    end

    # TODO: `ThemeRepository#current=` writes a file but doesn't validate
    # the theme exists in `all`**. There's no error handling — if you set
    # an invalid theme name, you'd only find out later when `ThemeSet#call`
    # tries to `File.join(@theme_path, theme_name)` and fails.
    def current=(theme_name)
      raise ArgumentError, "Theme not found: #{theme_name}" unless all.value?(theme_name)

      FileUtils.mkdir_p(File.dirname(current_theme_file))
      File.write(current_theme_file, theme_name)
    end

    private

    def themes
      Dir.glob(File.join(@theme_path, '/*/')).map { |d| File.basename(d) }
    end

    def current_theme_file
      File.join(@hyperion_path, 'current', 'theme.current')
    end
  end
end

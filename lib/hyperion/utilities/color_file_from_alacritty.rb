# frozen_string_literal: true

module Utilities
  # Extracts a colorscheme file from existing Alacritty file
  class ColorFileFromAlacritty
    def initialize(theme_source)
      @theme_source = theme_source
    end

    def colors_output
      @colors_output ||= File.join(@theme_source, 'colors.toml')
    end

    def alacritty_file
      @alacritty_file ||= File.join(@theme_source, 'alacritty.toml')
    end

    def extract
      raw_toml = TomlRB.load_file(alacritty_file, symbolize_keys: true)
      config = AlacrittyConfig.new(raw_toml)

      write_colors_file(config)
    end

    def write_colors_file(config)
      File.write(colors_output, TomlRB.dump(config.to_h))
    end
  end
end

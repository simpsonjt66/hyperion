# frozen_string_literal: true

module Utilities
  # Handles color string transformation (hex, stripped hex, rgb)
  class ColorTransformer
    def self.substitutions_for(colors)
      colors.each_with_object({}) do |(key, value), result|
        result["{{ #{key} }}"]       = value
        result["{{ #{key}_strip }}"] = value.delete_prefix('#')
        result["{{ #{key}_rgb }}"]   = hex_to_rgb(value) if value.to_s.start_with?('#')
      end
    end

    def self.hex_to_rgb(hex)
      r, g, b = hex.delete_prefix('#').scan(/../).map(&:hex)
      "#{r},#{g},#{b}"
    end
  end

  # A generic, efficient regex-based template renderer
  class TemplateRenderer
    def initialize(substitutions)
      @substitutions = substitutions
      @pattern = Regexp.union(substitutions.keys)
    end

    def render(text)
      text.gsub(@pattern, @substitutions)
    end
  end

  # Orchestrates the building of the theme files
  class ThemeSetTemplate
    TEMPLATES_PATH = File.join(HYPERION_PATH, 'templates').freeze
    NEXT_THEME_PATH = File.join(HYPERION_PATH, 'next_theme').freeze

    def initialize(theme_dir)
      @colors_file = File.join(theme_dir, 'colors.toml')
    end

    def build_config_files
      return puts "Color file missing: #{@colors_file}" unless File.exist?(@colors_file)

      colors = TomlRB.load_file(@colors_file)

      subs = ColorTransformer.substitutions_for(colors)
      renderer = TemplateRenderer.new(subs)

      Dir.glob(File.join(TEMPLATES_PATH, '*.tpl')).each do |tpl_path|
        output_path = File.join(NEXT_THEME_PATH, File.basename(tpl_path, '.tpl'))

        next if File.exist?(output_path)

        content = File.read(tpl_path)
        File.write(output_path, renderer.render(content))
      end
    end
  end
end

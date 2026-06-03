# frozen_string_literal: true

module Utilities
  # Manages font configuration
  class FontManager
    def initialize(config_path: CONFIG_PATH, hyperion_path: HYPERION_PATH)
      @config_path = config_path
      @hyperion_path = hyperion_path
    end

    def terminal_font_list
      `fc-list :spacing=100 -f "%{family[0]}\n"`.lines.map(&:strip).sort.uniq
    end

    def current_font
      return File.read(current_font_file).strip if File.exist?(current_font_file)

      return unless File.exist?(kitty_config_file)

      read_font_from_kitty(File.read(kitty_config_file))
    end

    def update_fonts(new_font)
      update_current_font_file(new_font)
      update_kitty_font(new_font)
    end

    private

    def update_current_font_file(new_font)
      File.write(current_font_file, new_font)
    end

    def update_kitty_font(new_font)
      return unless File.exist?(kitty_config_file)

      content = File.read(kitty_config_file)
      old_font = read_font_from_kitty(content)
      return unless old_font

      new_content = content.gsub(/^font_family\s+#{Regexp.escape(old_font)}\s*$/, "font_family      #{new_font}")
      File.write(kitty_config_file, new_content)
    end

    def current_font_file
      File.join(@hyperion_path, 'current', 'font.current')
    end

    def kitty_config_file
      File.join(@config_path, 'kitty', 'kitty.conf')
    end

    def read_font_from_kitty(content)
      match = content.match(/^font_family\s+(.+)$/)
      match ? match[1].strip : nil
    end
  end
end

# frozen_string_literal: true

module Applications
  # Neovim application management
  class Nvim < Base
    def reload_config
      stdout, _stderr, _status = Open3.capture3('ls $XDG_RUNTIME_DIR/nvim.*')
      cleaned = stdout.strip
      paths = cleaned.split(/\R/)
      paths.each do |path|
        system("nvim --server #{path} --remote-send ':colorscheme #{theme}<CR>'")
      end
    end

    def theme
      theme_file = File.join(Utilities::CURRENT_THEME_PATH, 'neovim.theme')
      File.read(theme_file).strip
    end
  end
end

# frozen_string_literal: true

module Applications
  # Neovim application management
  class Nvim < Base
    def reload_config
      paths = Dir.glob(File.join(ENV['XDG_RUNTIME_DIR'] || '', 'nvim.*'))
      paths.each do |path|
        system("nvim --server #{path} --remote-send ':colorscheme #{theme}<CR>'")
      end
    end

    def theme
      return '' unless @theme_repository

      current_theme = @theme_repository.current
      theme_file = File.join(@theme_repository.theme_path, current_theme, 'neovim.theme')
      File.read(theme_file).strip
    end
  end
end

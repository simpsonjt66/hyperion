# frozen_string_literal: true

module Utilities
  # Default strategy for extracting colors from Alacritty configs
  class ColorExtractor
    def self.call(staging_path)
      return if File.exist?(File.join(staging_path, 'colors.toml'))

      ColorFileFromAlacritty.new(staging_path).extract
    end
  end

  # Default strategy for building config files from templates
  class TemplateBuilder
    def self.call(staging_path)
      ThemeSetTemplate.new(staging_path).build_config_files
    end
  end

  # Orchestrates the theme application process
  class ThemeSet
    attr_reader :applications

    def initialize(theme_repository: ThemeRepository.new, applications: nil, **options)
      @theme_repository = theme_repository
      @applications     = applications || default_applications
      @theme_deployer   = options.fetch(:theme_deployer, ThemeDeployer.new)
      @theme_path       = options.fetch(:theme_path, THEME_PATH)
      @color_extractor  = options.fetch(:color_extractor, ColorExtractor)
      @template_builder = options.fetch(:template_builder, TemplateBuilder)
    end

    def call(theme_name)
      source_path = File.join(@theme_path, theme_name)
      staging_path = @theme_deployer.staging_path

      @theme_deployer.prepare_staging(source_path)

      compile_assets(staging_path)

      @theme_deployer.publish
      @theme_repository.current = theme_name
      reload_configs
    end

    private

    def compile_assets(staging_path)
      @color_extractor.call(staging_path)
      @template_builder.call(staging_path)
    end

    def reload_configs
      @applications.each_value(&:reload_config)
    end

    def default_applications
      {
        waybar: Applications::Waybar.new,
        kitty: Applications::Kitty.new,
        nvim: Applications::Nvim.new(theme_repository: @theme_repository)
      }
    end
  end
end

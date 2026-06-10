# frozen_string_literal: true

module Utilities
  # Orchestrates the theme application process
  class ThemeSet
    attr_reader :applications

    def initialize(
      applications: {
        waybar: Applications::Waybar.new,
        kitty: Applications::Kitty.new,
        nvim: Applications::Nvim.new
      },
      theme_repository: ThemeRepository.new,
      theme_deployer: ThemeDeployer.new,
      theme_path: THEME_PATH,
      color_extractor: ->(path) { ColorFileFromAlacritty.new(path) },
      template_builder: ->(path) { ThemeSetTemplate.new(path) }
    )
      @applications = applications
      @theme_repository = theme_repository
      @theme_deployer = theme_deployer
      @theme_path = theme_path
      @color_extractor = color_extractor
      @template_builder = template_builder
    end

    def call(theme_name)
      source_path = File.join(@theme_path, theme_name)
      staging_path = @theme_deployer.staging_path

      @theme_deployer.prepare_staging(source_path)

      process_assets(staging_path)

      @theme_deployer.publish
      @theme_repository.current = theme_name
      reload_configs
    end

    private

    def process_assets(staging_path)
      @color_extractor.call(staging_path).extract unless File.exist?(File.join(staging_path, 'colors.toml'))

      @template_builder.call(staging_path).build_config_files
    end

    def reload_configs
      @applications.each_value(&:reload_config)
    end
  end
end

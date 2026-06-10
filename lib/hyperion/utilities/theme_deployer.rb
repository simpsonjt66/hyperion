# frozen_string_literal: true

require 'fileutils'

module Utilities
  # Handles low-level filesystem orchestration for theme deployment
  class ThemeDeployer
    attr_reader :staging_path

    def initialize(staging_path: NEXT_THEME_PATH, current_path: CURRENT_THEME_PATH)
      @staging_path = staging_path
      @current_path = current_path
    end

    def prepare_staging(source_path)
      cleanup_staging
      FileUtils.mkdir_p(@staging_path)
      FileUtils.cp_r(File.join(source_path, '/.'), @staging_path)
    end

    def publish
      FileUtils.rm_rf(@current_path)
      FileUtils.mkdir_p(File.dirname(@current_path))
      FileUtils.mv(@staging_path, @current_path)
    end

    def cleanup_staging
      FileUtils.rm_rf(@staging_path) if File.exist?(@staging_path)
    end
  end
end

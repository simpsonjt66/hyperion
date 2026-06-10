# frozen_string_literal: true

module Menus
  # Menu to list and select current themes
  class Theme < Base
    def initialize(
      theme_set: Utilities::ThemeSet.new,
      theme_repository: Utilities::ThemeRepository.new,
      **kwargs
    )
      super(**kwargs)
      @theme_set = theme_set
      @theme_repository = theme_repository
    end

    def show
      selected = @view.select(**menu_options)

      return { action: :back } if selected.nil?

      @view.notify("Theme set to #{selected}")
      @theme_set.call(theme_list[selected])
      { action: :exit }
    end

    private

    def theme_list
      @theme_repository.all
    end

    def current_theme
      @theme_repository.current
    end

    def default_selection
      current_theme && theme_list.key(current_theme) || nil
    end

    def menu_options
      {
        items: theme_list.keys,
        current: default_selection,
        prompt: 'Select'
      }
    end
  end
end

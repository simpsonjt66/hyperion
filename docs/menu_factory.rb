# frozen_string_literal: true

require_relative 'menus/apps'
require_relative 'menus/browser'
require_relative 'menus/config'
require_relative 'menus/default'
require_relative 'menus/editor'
require_relative 'menus/font'
require_relative 'menus/main'
require_relative 'menus/package'
require_relative 'menus/system'
require_relative 'menus/terminal'
require_relative 'menus/theme'

module Hyperion
  # The MenuFactory is responsible for instantiating menu objects with their
  # required dependencies (options and view). This implements the Coordinator
  # pattern, decoupling menus from the global configuration and each other
  class MenuFactory
    # Mapping of route symbols to their respective menu classes and config keys

    ROUTES = { main: { class: ::Menus::Main, options_key: :main_menu },
               system: { class: ::Menus::System, options_key: :system_menu },
               config: { class: ::Menus::Config, options_key: :config_menu },
               package: { class: ::Menus::Package, options_key: :package_menu },
               default: { class: ::Menus::Default, options_key: :default_menu },
               editor: { class: ::Menus::Editor, options_key: :default_editor_menu },
               browser: { class: ::Menus::Browser, options_key: :default_browser_menu },
               terminal: { class: ::Menus::Terminal, options_key: :default_terminal_menu },
               apps: { class: ::Menus::Apps, options_key: nil },
               font: { class: ::Menus::Font, options_key: nil },
               theme: { class: ::Menus::Theme, options_key: nil } }.freeze

    # Builds a menu instance for the given route
    # @param route [Symbol] The route identifier (e.g., :main, :system)
    # @param options_hash [Hash] The global configuration options (e.g., OPTIONS)
    # @param view [Object] The UI/View adapter (e.g., Utilities)
    # @return [Menus::Base] A fully initialized menu instance

    def self.build(route, options_hash, view)
      config = ROUTES[route]
      raise ArgumentError, "Unknown route: #{route}" unless config

      options = if config[:options_key]
                  options_hash[config[:options_key]]
                else
                  []
                end
      config[:class].new(options: options, view: view)
    end
  end
end

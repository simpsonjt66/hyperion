#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/hyperion'

CONFIG_PATH = File.expand_path(ENV['XDG_CONFIG_HOME'])
CONFIG_FILE = File.join(CONFIG_PATH, 'hyperion', 'config.yaml')
OPTIONS = YAML.load_file(CONFIG_FILE, symbolize_names: true)

view = Hyperion::View::RofiAdapter.new

# Method to manage menu navigation, should return
# to parent menu when Esc is pressed.

initial_route = (ARGV[0] || 'main').to_sym

Hyperion::Navigator.new(initial_route, OPTIONS, view).run

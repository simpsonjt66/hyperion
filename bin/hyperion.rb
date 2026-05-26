#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'English'
require 'yaml'
require_relative('../lib/hyperion/utilities')

CONFIG_PATH = File.expand_path(ENV['XDG_CONFIG_HOME'])
CONFIG_FILE = File.join(CONFIG_PATH, 'hyperion', 'config.yaml')
OPTIONS = YAML.load_file(CONFIG_FILE, symbolize_names: true)

# Method to manage menu navigation, should return
# to parent menu when Esc is pressed.
class Navigator
  def initialize(start_menu_class)
    @stack = [start_menu_class]
  end

  def run
    while @stack.any?
      current_menu = @stack.last

      result = current_menu.show

      case result[:action]
      when :push
        @stack.push(result[:target])
      when :back
        @stack.pop
      when :exit
        @stack.clear
      else
        @stack.clear
      end
    end
  end
end

initial_name = ARGV[0] || 'main'
begin
  start_class = Menus.const_get(initial_name.capitalize)
  Navigator.new(start_class).run
rescue NameError
  puts "Menu #{initial_name} not found."
  exit 1
end

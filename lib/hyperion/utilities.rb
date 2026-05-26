# frozen_string_literal: true

require 'fileutils'
require 'toml-rb'

# Utility functions for app launcher
module Utilities
  data_path = ENV['XDG_DATA_HOME'] || File.join(Dir.home, '.local', 'share')

  HYPERION_PATH = File.join(data_path, 'hyperion')
  THEME_PATH = File.join(HYPERION_PATH, 'themes')
  CURRENT_THEME_PATH = File.join(HYPERION_PATH, 'current', 'theme')

  def self.rofi_select(items:, current: nil, prompt: 'Launch')
    current_index = items.index(current) || 0

    result = IO.popen(rofi_command(items, current_index, prompt), 'r+') do |io|
      io.puts items
      io.close_write
      io.read.chomp
    end

    $CHILD_STATUS.success? && !result.empty? ? result : nil
  end

  def self.confirm_dialog(message)
    system('confirm-dialog', '-m', message)
  end

  def self.rofi_command(items, current_index, prompt)
    longest = items.max_by(&:length)&.length || 0

    [
      'rofi',
      '-dmenu',
      '-p', prompt,
      '-selected-row', current_index.to_s,
      '-i', '-l', items.size.to_s,
      '-theme', '~/.config/rofi/themes/system-menu.rasi',
      '-theme-str', "window { width: #{longest}em;}"
    ]
  end
end

Dir.glob(File.join(__dir__, '{menus,utilities}', '*.rb'))
   .sort.each { |f| require f }

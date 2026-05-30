# frozen_string_literal: true

require 'open3'
require 'English'
require 'yaml'
require 'fileutils'
require 'toml-rb'

require_relative 'hyperion/version'
require_relative 'hyperion/utilities'
require_relative 'hyperion/view/rofi_adapter'

# Load all utilities
Dir.glob(File.join(__dir__, 'hyperion/utilities', '*.rb')).sort.each { |f| require f }

require_relative 'hyperion/menus/base'

# Load all menus
Dir.glob(File.join(__dir__, 'hyperion/menus', '*.rb')).sort.each { |f| require f }

require_relative 'hyperion/menu_factory'
require_relative 'hyperion/navigator'

module Hyperion
  class Error < StandardError; end
end

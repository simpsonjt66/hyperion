# frozen_string_literal: true

require_relative 'base'

module Applications
  # Manages external command hyprsunset
  class Hyprsunset < Base
    def name
      'hyprsunset'
    end

    def launch_command
      'uwsm-app -- hyprsunset -t 4000'
    end
  end
end

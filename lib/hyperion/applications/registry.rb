# frozen_string_literal: true

require_relative 'waybar'
require_relative 'hypridle'
require_relative 'hyprsunset'

module Applications
  # External applications management
  class Registry
    attr_reader :all

    def initialize(apps = [Waybar.new, Hypridle.new, Hyprsunset.new])
      @all = apps
    end

    def names
      all.map { |obj| obj.name.capitalize }
    end

    def statuses
      all.map(&:running?)
    end

    def prompts
      names.zip(statuses).map { |name, running| "#{running ? '' : ''}   #{name}" }
    end
  end
end

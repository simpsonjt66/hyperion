# frozen_string_literal: true

module Applications
  # Manages Kitty states and settings
  class Kitty < Base
    def name
      'kitty'
    end

    def reload_config
      stdout, _stderr, _status = Open3.capture3("pgrep -x #{name}")
      pids = stdout.split.map(&:to_i)
      pids.each { |pid| Process.kill('SIGUSR1', pid) }
    end
  end
end

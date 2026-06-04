# frozen_string_literal: true

require 'open3'

# Module to namespace all of the applications under management.
module Applications
  # Base class for applications.
  class Base
    def initialize; end

    def name
      raise NotImplementedError, "#{self.class} must implement #name"
    end

    def launch_command
      "uwsm-app -- #{name}"
    end

    def running?
      _stdout, _stderr, status = Open3.capture3("pgrep -x #{name}")
      status.success?
    end

    def start
      return if running?

      Process.spawn(launch_command, out: File::NULL, err: File::NULL)
    end

    def stop
      return unless running?

      _stdout, _stderr, status = Open3.capture3("pkill -x #{name}")
      status.success?
    end

    def restart
      stop
      sleep 1
      start
    end
  end
end

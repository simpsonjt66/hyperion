# frozen_string_literal: true

require 'open3'

# Module to namespace all of the applications under management.
module Applications
  # Base class for applications.
  class Base
    def name
      raise NotImplementedError, "#{self.class} must implement #name"
    end

    def launch_command
      "uwsm-app -- #{name}"
    end

    def running?
      _stdout, _stderr, status = Open3.capture3('pgrep', '-x', name)
      status.success?
    end

    def toggle
      if running?
        stop
        :stopped
      else
        start
        :started
      end
    end

    def start
      return if running?

      pid = Process.spawn(launch_command, out: File::NULL, err: File::NULL)
      Process.detach(pid)
    end

    def stop
      return false unless running?

      _stdout, _stderr, status = Open3.capture3('pkill', '-x', name)
      status.success?
    end

    def restart(max_wait: 2.0)
      stop
      delay = 0.01
      waited = 0.0
      while waited < max_wait && running?
        sleep delay
        waited += delay
        delay = [delay * 2, 0.5].min
      end
      start
    end
  end
end

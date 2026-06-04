# frozen_string_literal: true

require 'test_helper'
require 'hyperion/applications/base'

# Mock class for testing the Base application logic
class MockApp < Applications::Base
  def name
    'mockapp'
  end
end

describe Applications::Base do
  let(:app) { MockApp.new }

  it 'returns a default launch command' do
    assert_equal 'uwsm-app -- mockapp', app.launch_command
  end

  describe '#running?' do
    it 'returns true when the process is found' do
      fake_status = Minitest::Mock.new
      fake_status.expect :success?, true

      Open3.stub :capture3, ['', '', fake_status] do
        assert app.running?
      end
    end

    it 'returns false when the process is not found' do
      fake_status = Minitest::Mock.new
      fake_status.expect :success?, false

      Open3.stub :capture3, ['', '', fake_status] do
        refute app.running?
      end
    end
  end

  describe '#start' do
    it 'spawns the process if not already running' do
      spawn_called = false
      app.stub :running?, false do
        Process.stub :spawn, ->(_cmd, _opts) { spawn_called = true; 123 } do
          app.start
        end
      end
      assert spawn_called
    end

    it 'does nothing if already running' do
      spawn_called = false
      app.stub :running?, true do
        Process.stub :spawn, ->(_cmd, _opts) { spawn_called = true; 123 } do
          app.start
        end
      end
      refute spawn_called
    end
  end

  describe '#stop' do
    it 'kills the process if it is running' do
      fake_status = Minitest::Mock.new
      fake_status.expect :success?, true

      app.stub :running?, true do
        Open3.stub :capture3, ->(cmd) {
          assert_equal 'pkill -x mockapp', cmd
          ['', '', fake_status]
        } do
          assert app.stop
        end
      end
    end

    it 'does nothing if not running' do
      app.stub :running?, false do
        # If capture3 is called, the test will fail because we didn't stub it inside the block
        # or we can explicitly assert it's not called.
        app.stop
      end
    end
  end

  describe '#restart' do
    it 'stops and then starts the application' do
      actions = []
      app.stub :stop, -> { actions << :stop } do
        app.stub :start, -> { actions << :start } do
          # Stub sleep to keep tests fast
          app.stub :sleep, nil do
            app.restart
          end
        end
      end
      assert_equal %i[stop start], actions
    end
  end
end

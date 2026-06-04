# test/hyperion/applications/hypridle_test.rb

require 'test_helper'
require 'hyperion/applications/hypridle'

describe Applications::Hypridle do
  let(:hypridle) { Applications::Hypridle.new }

  it 'initializes with new' do
    assert_instance_of Applications::Hypridle, hypridle
  end

  it 'returns a name' do
    assert_equal 'hypridle', hypridle.name
  end

  it 'returns a launch command' do
    assert_equal 'uwsm-app -- hypridle', hypridle.launch_command
  end
end

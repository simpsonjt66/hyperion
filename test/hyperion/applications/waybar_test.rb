# test/hyperion/applications/waybar_test.rb

require 'test_helper'
require 'hyperion/applications/waybar'

describe Applications::Waybar do
  let(:waybar) { Applications::Waybar.new }

  it 'initiializes with new' do
    assert_instance_of Applications::Waybar, waybar
  end

  it 'returns a name' do
    assert_equal 'waybar', waybar.name
  end

  it 'returns a launch command' do
    assert_equal 'uwsm-app -- waybar', waybar.launch_command
  end
end

# frozen_string_literal: true

# test/hyperion/applications/hyprsunset_test
require 'test_helper'
require 'hyperion/applications/hyprsunset'

describe Applications::Hyprsunset do
  let(:hyprsunset) { Applications::Hyprsunset.new }

  it 'initializes with new' do
    assert_instance_of Applications::Hyprsunset, hyprsunset
  end

  it 'returns a name' do
    assert_equal hyprsunset.name, 'hyprsunset'
  end

  it 'returns a launch command' do
    assert_equal hyprsunset.launch_command, 'uwsm-app -- hyprsunset -t 4000'
  end
end

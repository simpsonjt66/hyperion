# test/hyperion/applications/registry_test.rb
require 'test_helper'
require 'hyperion/applications/registry'

describe 'Applications::Registry' do
  let(:applications) { Applications::Registry.new }

  it 'Initializes with new' do
    assert_instance_of Applications::Registry, applications
  end

  it 'returns an array with all' do
    result = applications.all

    assert_instance_of Array, result
  end

  it 'returns an instance of Waybar' do
    contains_waybar = applications.all.any? { |application| application.is_a?(Applications::Waybar) }

    assert_equal true, contains_waybar
  end

  it 'returns an instance of Hypridle' do
    contains_hypridle = applications.all.any? { |application| application.is_a?(Applications::Hypridle) }

    assert_equal true, contains_hypridle
  end
end

# test/hyperion/applications/applications_test.rb
require 'test_helper'
require 'hyperion/applications/applications'

describe 'Applications::Applications' do
  let(:applications) { Applications::Applications.new }

  it 'Initializes with new' do
    assert_instance_of Applications::Applications, applications
  end

  it 'returns an array with all' do
    result = applications.all

    assert_instance_of Array, result
  end

  it 'returns an instance of Waybar' do
    contains_waybar = applications.all.any? { |application| application.is_a?(Applications::Waybar) }

    assert_equal true, contains_waybar
  end
end

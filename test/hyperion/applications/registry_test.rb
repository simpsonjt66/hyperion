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

  it 'returns an instance of Hyprsunset' do
    contains_hyprsunset = applications.all.any? { |application| application.is_a?(Applications::Hyprsunset) }

    assert_equal true, contains_hyprsunset
  end

  it 'returns an array of names' do
    names = applications.names

    assert_equal %w[Waybar Hypridle Hyprsunset], names
  end

  describe '#statuses' do
    it 'returns the running status of each application using mocks' do
      # Create mock applications
      app1 = Minitest::Mock.new
      app1.expect :running?, true

      app2 = Minitest::Mock.new
      app2.expect :running?, false

      app3 = Minitest::Mock.new
      app3.expect :running?, true

      # Inject mocks into a new Registry instance
      registry = Applications::Registry.new([app1, app2, app3])

      assert_equal [true, false, true], registry.statuses

      # Verify that running? was actually called on the mocks
      app1.verify
      app2.verify
      app3.verify
    end
  end

  describe '#prompts' do
    it 'returns formatted prompt strings based on application state' do
      # Create mock applications
      app1 = Minitest::Mock.new
      app1.expect :name, 'waybar'
      app1.expect :running?, true

      app2 = Minitest::Mock.new
      app2.expect :name, 'hypridle'
      app2.expect :running?, false

      # Inject mocks
      registry = Applications::Registry.new([app1, app2])

      # Assert the formatted output
      expected = ['   Waybar', '   Hypridle']
      assert_equal expected, registry.prompts

      # Verify mocks
      app1.verify
      app2.verify
    end
  end
end

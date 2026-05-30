# frozen_string_literal: true

require 'test_helper'
require 'hyperion/navigator'
require 'hyperion/menu_factory'
require 'minitest/mock'

describe Hyperion::Navigator do
  let(:options) { { some: 'config' } }
  let(:view) { Object.new }
  let(:initial_route) { :main }
  let(:navigator) { Hyperion::Navigator.new(initial_route, options, view) }

  describe '#run' do
    it 'terminates when the stack is empty after a :back action' do
      mock_menu = Minitest::Mock.new
      mock_menu.expect :show, { action: :back }

      Hyperion::MenuFactory.stub :build, mock_menu do
        navigator.run
      end

      mock_menu.verify
    end

    it 'terminates immediately on :exit action' do
      mock_menu = Minitest::Mock.new
      mock_menu.expect :show, { action: :exit }

      Hyperion::MenuFactory.stub :build, mock_menu do
        navigator.run
      end

      mock_menu.verify
    end

    it 'pushes a new route and then pops back' do
      main_menu = Minitest::Mock.new
      sub_menu = Minitest::Mock.new

      main_menu.expect :show, { action: :push, target: :sub }
      sub_menu.expect :show, { action: :back }
      main_menu.expect :show, { action: :back }

      # We need a way to return different menus for different routes
      build_stub = lambda do |route, opts, v|
        assert_equal options, opts
        assert_equal view, v
        case route
        when :main then main_menu
        when :sub then sub_menu
        else flunk "Unexpected route: #{route}"
        end
      end

      Hyperion::MenuFactory.stub :build, build_stub do
        navigator.run
      end

      main_menu.verify
      sub_menu.verify
    end

    it 'clears the stack on an unknown action' do
      mock_menu = Minitest::Mock.new
      mock_menu.expect :show, { action: :unknown }

      Hyperion::MenuFactory.stub :build, mock_menu do
        navigator.run
      end

      mock_menu.verify
    end

    it 'clears the stack if :action key is missing' do
      mock_menu = Minitest::Mock.new
      mock_menu.expect :show, {}

      Hyperion::MenuFactory.stub :build, mock_menu do
        navigator.run
      end

      mock_menu.verify
    end

    it 'handles multiple pushes and then exit' do
      main_menu = Minitest::Mock.new
      sub_menu1 = Minitest::Mock.new
      sub_menu2 = Minitest::Mock.new

      main_menu.expect :show, { action: :push, target: :sub1 }
      sub_menu1.expect :show, { action: :push, target: :sub2 }
      sub_menu2.expect :show, { action: :exit }

      build_stub = lambda do |route, _, _|
        case route
        when :main then main_menu
        when :sub1 then sub_menu1
        when :sub2 then sub_menu2
        end
      end

      Hyperion::MenuFactory.stub :build, build_stub do
        navigator.run
      end

      main_menu.verify
      sub_menu1.verify
      sub_menu2.verify
    end
  end
end

# frozen_string_literal: true

require 'test_helper'
require 'hyperion/environment'

describe Utilities do
  let(:data_path) { File.expand_path('~/.local/share') }
  let(:hyperion_path) { File.join(data_path, 'hyperion') }
  let(:theme_path) { File.join(hyperion_path, 'themes') }
  let(:current_theme_path) { File.join(hyperion_path, 'current', 'theme') }
  let(:next_theme_path) { File.join(hyperion_path, 'next_theme') }
  let(:templates_path) { File.join(hyperion_path, 'templates') }
  let(:config_path) { File.join(Dir.home, '.config') }

  it 'defines the correct contstants' do
    _(Utilities::DATA_PATH).must_equal data_path
    _(Utilities::HYPERION_PATH).must_equal hyperion_path
    _(Utilities::THEME_PATH).must_equal theme_path
    _(Utilities::CURRENT_THEME_PATH).must_equal current_theme_path
    _(Utilities::NEXT_THEME_PATH).must_equal next_theme_path
    _(Utilities::TEMPLATES_PATH).must_equal templates_path
    _(Utilities::CONFIG_PATH).must_equal config_path
  end
end

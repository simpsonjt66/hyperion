# frozen_string_literal: true

require 'test_helper'
require 'hyperion/utilities/theme_repository'
require 'tmpdir'

describe Utilities::ThemeRepository do
  before do
    @tmp_dir = Dir.mktmpdir
    @theme_path = File.join(@tmp_dir, 'themes')
    @hyperion_path = @tmp_dir
    FileUtils.mkdir_p(@theme_path)
    FileUtils.mkdir_p(File.join(@theme_path, 'catppuccin'))
    FileUtils.mkdir_p(File.join(@theme_path, 'tokyo-night'))
  end

  after do
    FileUtils.rm_rf(@tmp_dir)
  end

  let(:repository) { Utilities::ThemeRepository.new(theme_path: @theme_path, hyperion_path: @hyperion_path) }

  describe '#all' do
    it 'returns a hash of human-readable names to directory names' do
      expected = {
        'Catppuccin' => 'catppuccin',
        'Tokyo Night' => 'tokyo-night'
      }
      assert_equal expected, repository.all
    end
  end

  describe '#current' do
    it 'returns nil if no current theme file exists' do
      assert_nil repository.current
    end

    it 'returns the theme name if the file exists' do
      marker_path = File.join(@hyperion_path, 'current', 'theme.current')
      FileUtils.mkdir_p(File.dirname(marker_path))
      File.write(marker_path, 'nord')
      assert_equal 'nord', repository.current
    end
  end

  describe '#current=' do
    it 'writes the theme name to the current theme file' do
      repository.current = 'flexoki-light'
      marker_path = File.join(@hyperion_path, 'current', 'theme.current')
      assert_equal 'flexoki-light', File.read(marker_path)
    end

    it 'creates the directory if it does not exist' do
      repository.current = 'matte-black'
      assert File.exist?(File.join(@hyperion_path, 'current', 'theme.current'))
    end
  end
end

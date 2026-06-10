# frozen_string_literal: true

require 'test_helper'
require 'hyperion/utilities/theme_deployer'
require 'tmpdir'

describe Utilities::ThemeDeployer do
  before do
    @tmp_dir = Dir.mktmpdir
    @source_path = File.join(@tmp_dir, 'source')
    @staging_path = File.join(@tmp_dir, 'staging')
    @current_path = File.join(@tmp_dir, 'current')

    FileUtils.mkdir_p(@source_path)
    File.write(File.join(@source_path, 'config.txt'), 'content')
  end

  after do
    FileUtils.rm_rf(@tmp_dir)
  end

  let(:deployer) { Utilities::ThemeDeployer.new(staging_path: @staging_path, current_path: @current_path) }

  describe '#prepare_staging' do
    it 'cleans up existing staging and copies source files' do
      FileUtils.mkdir_p(@staging_path)
      File.write(File.join(@staging_path, 'old.txt'), 'old')

      deployer.prepare_staging(@source_path)

      assert File.exist?(File.join(@staging_path, 'config.txt'))
      refute File.exist?(File.join(@staging_path, 'old.txt'))
    end
  end

  describe '#publish' do
    it 'moves staging to current, removing existing current' do
      FileUtils.mkdir_p(@staging_path)
      File.write(File.join(@staging_path, 'new.txt'), 'new')

      FileUtils.mkdir_p(@current_path)
      File.write(File.join(@current_path, 'old.txt'), 'old')

      deployer.publish

      assert File.exist?(File.join(@current_path, 'new.txt'))
      refute File.exist?(File.join(@current_path, 'old.txt'))
      refute File.exist?(@staging_path)
    end
  end

  describe '#cleanup_staging' do
    it 'removes the staging directory' do
      FileUtils.mkdir_p(@staging_path)
      deployer.cleanup_staging
      refute File.exist?(@staging_path)
    end
  end
end

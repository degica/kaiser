# frozen_string_literal: true

require 'kaiser/kaiserfile'

RSpec.describe Kaiser::Kaiserfile do
  # Defaults
  let(:kaiserfile_name) { 'Kaiserfile' }
  let(:dockerfile_name) { 'Dockerfile' }

  let(:kaiserfile) { '' }
  let(:dockerfile) { '' }

  before do
    allow(File).to receive(:exist?) { true }
    allow(File).to receive(:read).with(kaiserfile_name) { kaiserfile_contents }
    allow(File).to receive(:read).with(dockerfile_name) { dockerfile_contents }

    allow(Kaiser::Config).to receive(:kaiserfile) { Kaiser::Kaiserfile.new('Kaiserfile') }
  end

  context 'db platform set' do
    let(:kaiserfile_contents) { <<-KAISERFILE }
        db 'postgres:alpine',
           platform: 'linux/amd64',
           data_dir: '/var/lib/postgresql/data',
           port: 5432

    KAISERFILE

    it 'sets the platform' do
      cli = Kaiser::Cli.new
      expect(cli.send(:db_image)).to eq('--platform linux/amd64 postgres:alpine')
    end
  end

  context 'db platform not set' do
    let(:kaiserfile_contents) { <<-KAISERFILE }
        db 'postgres:alpine',
           data_dir: '/var/lib/postgresql/data',
           port: 5432

    KAISERFILE

    it 'ignores platform' do
      cli = Kaiser::Cli.new
      expect(cli.send(:db_image)).to eq('postgres:alpine')
    end
  end

  describe '#selenium_node_image' do
    it 'for x86 machines returns normal selenium' do
      cli = Kaiser::Cli.new
      stub_const('RUBY_PLATFORM', 'x86_64-linux')
      expect(cli.send(:selenium_node_image)).to eq('selenium/standalone-chrome-debug')
    end

    it 'for arm machines on mac' do
      cli = Kaiser::Cli.new
      stub_const('RUBY_PLATFORM', 'arm64-darwin23')
      expect(cli.send(:selenium_node_image)).to eq('seleniarm/standalone-chromium')
    end

    it 'for arm machines on linux' do
      cli = Kaiser::Cli.new
      stub_const('RUBY_PLATFORM', 'aarch64-linux')
      expect(cli.send(:selenium_node_image)).to eq('seleniarm/standalone-chromium')
    end
  end
end

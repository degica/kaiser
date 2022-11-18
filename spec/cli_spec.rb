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
end

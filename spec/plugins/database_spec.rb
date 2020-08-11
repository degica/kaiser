# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Kaiser::Plugins::Database' do
  before do
    # stub out call that isnt supposed to be there anyway
    require 'optimist'
    allow(Optimist).to receive(:die)
  end

  let(:dockerfile_name) { 'Dockerfile.kaiser' }
  let(:kaiserfile_name) { 'Kaiserfile' }
  let(:dockerfile) { 'FROM ruby:alpine' }
  let(:kaiserfile) { <<~KAISERFILE }
    plugin :database
    dockerfile "Dockerfile.kaiser"
  KAISERFILE

  before do
    allow(File).to receive(:exist?) { true }
    allow(File).to receive(:read).with(kaiserfile_name) { kaiserfile }
    allow(File).to receive(:read).with(dockerfile_name) { dockerfile }
  end

  it 'throws an exception if nonexistent driver' do
    kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')

    expect { kaiserfile.def_db :nobase }.to raise_error "Unknown database 'nobase'"
  end

  context 'given a driver' do
    let(:db_class) { Class.new }
    let(:db_driver) { instance_double('Kaiser::Databases::Somebase') }

    before do
      stub_const('Kaiser::Databases::Somebase', db_class)
    end

    it 'accepts a symbol and loads the appropriate driver' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      allow(kaiserfile).to receive(:require).with('kaiser/databases/somebase') { true }

      expect(db_class).to receive(:new) { db_driver }
      expect(db_driver).to receive(:options_hash) { { port: 1234 } }
      expect(db_driver).to receive(:image_name) { '' }
      expect(kaiserfile).to receive(:db).with('', port: 1234)

      kaiserfile.def_db :somebase
    end

    it 'accepts a hash and loads the appropriate driver' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      allow(kaiserfile).to receive(:require).with('kaiser/databases/somebase') { true }

      expect(db_class).to receive(:new) { db_driver }.with(hello: :meow)
      expect(db_driver).to receive(:options_hash) { { port: 1234 } }
      expect(db_driver).to receive(:image_name) { '' }
      expect(kaiserfile).to receive(:db).with('', port: 1234)

      kaiserfile.def_db somebase: { hello: :meow }
    end
  end
end

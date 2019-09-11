# frozen_string_literal: true

require 'kaiser/kaiserfile'

RSpec.describe Kaiser::Kaiserfile, fixture_dir: 'kaiserfile' do
  it 'defines dockerfile' do
    cd 'app' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      expect(kaiserfile.docker_file_contents).to match(/FROM ruby:alpine/)
    end
  end
end

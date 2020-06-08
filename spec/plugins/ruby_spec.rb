# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kaiser::Ruby do
  let(:kaiserfile) { 'plugin :ruby' }
  let(:dockerfile) { 'FROM ruby:2.1.7' }

  before { setup_dummy_app }
  after { teardown_dummy_app }

  it 'raises an exception on missing git submodule' do
    create_file 'Kaiserfile', kaiserfile
    create_file 'Dockerfile.kaiser', dockerfile

    expect(run_command('kaiser up -v'))
      .to include("Found uninitialized git submodule 'degica'")
  end
end

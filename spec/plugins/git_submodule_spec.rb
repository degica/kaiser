# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Kaiser::Plugins::GitSubmodule' do
  let(:kaiserfile) { 'plugin :git_submodule' }

  before { setup_dummy_app }
  after { teardown_dummy_app }

  it 'raises an exception on missing git submodule' do
    create_file 'Kaiserfile', kaiserfile

    system <<-GIT_SETUP
    cd #{dummy_app}
    git init --quiet
    git submodule --quiet add https://github.com/degica/degica.git
    rm -rf degica
    GIT_SETUP

    expect(run_cmd('kaiser up -v'))
      .to include("Found uninitialized git submodule 'degica'")
  end
end

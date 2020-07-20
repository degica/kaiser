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
    allow(File).to receive(:read).with(kaiserfile_name) { kaiserfile }
    allow(File).to receive(:read).with(dockerfile_name) { dockerfile }
  end

  context '#dockerfile' do
    let(:dockerfile_name) { 'Dockerfile.kaiser' }
    let(:dockerfile) { 'FROM ruby:alpine' }
    let(:kaiserfile) { 'dockerfile "Dockerfile.kaiser"' }

    it 'loads the specified dockerfile' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      expect(kaiserfile.docker_file_contents).to match(/FROM ruby:alpine/)
    end
  end

  context '#attach_mount' do
    let(:kaiserfile) { 'attach_mount "bin", "/app/bin"' }

    it 'records the required mount attachments' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      expect(kaiserfile.attach_mounts).to contain_exactly(['bin', '/app/bin'])
    end
  end

  context '#db' do
    context 'with no db script' do
      let(:kaiserfile) { '' }

      it 'sets up the database variable to defaults' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.database[:image]).to eq 'alpine'
        expect(kaiserfile.database[:data_dir]).to eq '/tmp/data'
        expect(kaiserfile.database[:port]).to eq 1234
        expect(kaiserfile.database[:params]).to eq ''
        expect(kaiserfile.database[:commands]).to eq 'echo "no db"'
        expect(kaiserfile.database[:waitscript]).to eq 'echo "no dbwait"'
        expect(kaiserfile.database[:waitscript_params]).to eq ''
      end
    end

    context 'with a simple db script' do
      let(:kaiserfile) { <<-KAISERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/somedb/data',
           port: 1234

      KAISERFILE

      it 'sets up the database variable correctly' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.database[:image]).to eq 'somedb:version'
        expect(kaiserfile.database[:data_dir]).to eq '/var/lib/somedb/data'
        expect(kaiserfile.database[:port]).to eq 1234
      end
    end

    context 'with a simple db script with a startup command' do
      let(:kaiserfile) { <<-KAISERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/dbdb',
           port: 1414,
           commands: 'start_db'
      KAISERFILE

      it 'sets up the database variable with commands' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.database[:commands]).to eq 'start_db'
      end
    end

    context 'with a simple db script with a waitscript' do
      let(:kaiserfile) { <<-KAISERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/dbdb',
           port: 1414,
           waitscript: 'sh wait_for_db.sh'
      KAISERFILE

      it 'sets up the database variable with waitscript commands' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.database[:waitscript]).to eq 'sh wait_for_db.sh'
      end
    end

    context 'with a simple db script with a waitscript and parameters to the waitscript' do
      let(:kaiserfile) { <<-KAISERFILE }
        db 'somedb:version',
           data_dir: '/var/lib/dbdb',
           port: 1414,
           waitscript: 'sh wait_for_db.sh',
           waitscript_params: '-e PORT=1414'
      KAISERFILE

      it 'sets up the database variable with waitscript command params' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.database[:waitscript_params]).to eq '-e PORT=1414'
      end
    end
  end

  context '#expose' do
    let(:kaiserfile) { 'expose 1337' }

    it 'records the port used by the application' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      expect(kaiserfile.port).to eq 1337
    end
  end

  context '#app_params' do
    let(:kaiserfile) { 'app_params "--user me"' }

    it 'records the parameters to the docker container' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      expect(kaiserfile.params).to match(/--user me/)
    end

    context 'with two calls to app_params' do
      let(:kaiserfile) { <<~SCRIPT }
        app_params "-e SOMEPARAM=1"
        app_params "-e ANOTHERPARAM=2"
      SCRIPT

      it 'is additive' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.params).to match(/-e SOMEPARAM=1/)
        expect(kaiserfile.params).to match(/\s-e ANOTHERPARAM=2/)
      end
    end
  end

  context '#db_reset_command' do
    let(:kaiserfile) { 'db_reset_command "explosion"' }

    it 'records the database reset command' do
      kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
      expect(kaiserfile.database_reset_command).to eq 'explosion'
    end
  end

  context '#type' do
    context 'when http is specified' do
      let(:kaiserfile) { 'type :http' }
      it 'sets server type to http' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.server_type).to eq :http
      end
    end

    context 'when anything else specified' do
      let(:kaiserfile) { 'type :meow' }
      it 'throws an error' do
        expect do
          Kaiser::Kaiserfile.new('Kaiserfile')
        end.to raise_error 'Valid server types are: [:http]'
      end
    end
  end

  context '#service' do
    context 'when service is specified' do
      let(:kaiserfile) { "service 'santaclaus'" }

      it 'adds a service' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.services).to eq [
          { 'santaclaus' => { image: 'santaclaus' } }
        ]
      end
    end

    context 'when service is specified with image name' do
      let(:kaiserfile) { "service 'santaclaus', image: 'northpole/santaclaus'" }

      it 'adds a service with the image name' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.services).to eq [
          { 'santaclaus' => { image: 'northpole/santaclaus' } }
        ]
      end
    end

    context 'when service is specified with image name and tag' do
      let(:kaiserfile) { "service 'santaclaus', image: 'northpole/santaclaus:last_christmas'" }

      it 'adds a service with the image name' do
        kaiserfile = Kaiser::Kaiserfile.new('Kaiserfile')
        expect(kaiserfile.services).to eq [
          { 'santaclaus' => { image: 'northpole/santaclaus:last_christmas' } }
        ]
      end
    end
  end
end

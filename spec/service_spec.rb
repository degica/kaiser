# frozen_string_literal: true

require 'kaiser/service'

RSpec.describe Kaiser::Service do
  it 'has image' do
    s = Kaiser::Service.new('meow', 'santa', { image: 'np/santa:lol' })

    expect(s.image).to eq 'np/santa:lol'
  end

  it 'has shared_name' do
    s = Kaiser::Service.new('meow', 'santa', { image: 'np/santa:lol' })

    expect(s.shared_name).to eq 'meow-santa'
  end

  it 'has name' do
    s = Kaiser::Service.new('meow', 'santa', { image: 'np/santa:lol' })

    expect(s.name).to eq 'santa'
  end

  describe '#start_docker_command' do
    before do
      allow(Kaiser::Config).to receive(:config).and_return({ networkname: 'testnet' })
    end

    it 'provides a proper docker command' do
      s = Kaiser::Service.new('meow', 'santa', { image: 'np/santa:lol' })

      expect(s.start_docker_command).to eq 'docker run -d --name meow-santa --network testnet np/santa:lol'
    end

    it 'provides a command with envs' do
      s = Kaiser::Service.new('meow', 'santa', {
        image: 'np/santa:lol',
        env: {
          "HELLO" => "world"
        }
      })

      expect(s.start_docker_command).to eq 'docker run -d --name meow-santa --network testnet -e HELLO=world np/santa:lol'
    end

    it 'provides a command with binds' do
      s = Kaiser::Service.new('meow', 'santa', {
        image: 'np/santa:lol',
        binds: {
          "/home/user" => "/home/inside/container"
        }
      })

      expect(s.start_docker_command).to eq 'docker run -d --name meow-santa --network testnet -v /home/user:/home/inside/container np/santa:lol'
    end

    it 'provides a command with command' do
      s = Kaiser::Service.new('meow', 'santa', {
        image: 'np/santa:lol',
        command: 'hohoho'
      })

      expect(s.start_docker_command).to eq 'docker run -d --name meow-santa --network testnet np/santa:lol hohoho'
    end
  end
end

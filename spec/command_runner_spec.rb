# frozen_string_literal: true

require 'kaiser/command_runner'

RSpec.describe Kaiser::CommandRunner do
  # this is the core function of this class
  describe '#run_command' do
    it 'runs a simple command' do
      # out can also be $stderr or $stdout
      out = StringIO.new
      described_class.new(out, 'echo hello', {}).run_command
      expect(out.string).to eq <<~OUTPUT
        hello\r
        $? = 0
      OUTPUT
    end

    it 'can capture lines' do
      lines = []
      out = StringIO.new
      described_class.new(out, 'echo hello', {}).run_command do |line|
        lines << line
      end

      expect(lines).to eq ['hello']
    end

    it 'returns the 0 status if the command succeeds' do
      out = StringIO.new
      retval = described_class.new(out, 'true', {}).run_command
      expect(retval).to eq 0
    end

    it 'returns the 1 status if the command returns 1' do
      out = StringIO.new
      retval = described_class.new(out, 'false', {}).run_command
      expect(retval).to eq 1
    end

    it 'allows application of environment variables' do
      lines = []
      out = StringIO.new
      described_class.new(out, 'echo $HELLO', { 'HELLO' => 'WORLD' }).run_command do |line|
        lines << line
      end

      expect(lines).to eq ['WORLD']
    end

    it 'can capture lines' do
      lines = []
      out = StringIO.new
      described_class.new(out, 'echo hello', {}).run_command do |line|
        lines << line
      end

      expect(lines).to eq ['hello']
    end
  end

  describe '.run' do
    it 'adds the appropriate lines to output' do
      out = StringIO.new
      described_class.run(out, 'echo hello', env_vars: {})

      expect(out.string).to eq <<~OUTPUT
        > echo hello
        hello\r
        $? = 0
      OUTPUT
    end

    it 'yields lines approprately' do
      lines = []
      out = StringIO.new
      described_class.run(out, 'echo hello', env_vars: {}) do |line|
        lines << line
      end

      expect(lines).to eq ['hello']
    end

    it 'handles env vars' do
      lines = []
      out = StringIO.new
      described_class.run(out, 'echo $HELLO', env_vars: { 'HELLO' => 'world' }) do |line|
        lines << line
      end

      expect(lines).to eq ['world']
    end
  end

  describe '.run!' do
    out = StringIO.new
    it 'does whatever run does' do
      expect(described_class).to receive(:run).with(out, 'meow', env_vars: { 'FOO' => 'bar' }).and_return('0')

      described_class.run!(out, 'meow', env_vars: { 'FOO' => 'bar' })
    end

    it 'throws when the return code is not 0' do
      allow(described_class).to receive(:run).with(out, 'woof', env_vars: { 'FOO' => 'bar' }).and_return('1')

      expect { described_class.run!(out, 'woof', env_vars: { 'FOO' => 'bar' }) }
        .to raise_error Kaiser::CmdError
    end
  end
end

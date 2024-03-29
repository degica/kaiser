# frozen_string_literal: true

RSpec.describe Kaiser::Cmds::Up do
  describe 'cmd' do
    it 'generates correctly' do
      kaiserfile = double(Kaiser::Kaiserfile)
      kaiserconfig = double(Kaiser::Config)

      allow(Kaiser::Config).to receive(:kaiserfile).and_return(kaiserfile)
      allow(Kaiser::Config).to receive(:config).and_return(kaiserconfig)

      allow(Kaiser::Config).to receive(:work_dir).and_return('somedir')

      envs = double('Hash')
      allow(envs).to receive(:[]).with('somedir').and_return('meow')

      allow(Kaiser::Config.kaiserfile).to receive(:docker_build_args).and_return({})
      allow(Kaiser::Config.config).to receive(:[]).with(:envnames).and_return(envs)

      obj = described_class.new
      allow(obj).to receive(:current_branch).and_return('master')

      allow(kaiserfile).to receive(:platform).and_return('')

      expect(obj.build_cmd[0]).to eq 'docker build'
      expect(obj.build_cmd[1]).to eq '-t kaiser:meow-master'
      expect(obj.build_cmd[2]).to eq '-f /meow-dockerfile somedir'
      expect(obj.build_cmd[3].to_s).to eq ''
    end

    it 'generates the appropriate build platform' do
      kaiserfile = double(Kaiser::Kaiserfile)
      kaiserconfig = double(Kaiser::Config)

      allow(Kaiser::Config).to receive(:kaiserfile).and_return(kaiserfile)
      allow(Kaiser::Config).to receive(:config).and_return(kaiserconfig)

      allow(Kaiser::Config).to receive(:work_dir).and_return('somedir')

      envs = double('Hash')
      allow(envs).to receive(:[]).with('somedir').and_return('meow')

      allow(kaiserfile).to receive(:platform).and_return('linux/catcpu')

      allow(Kaiser::Config.kaiserfile).to receive(:docker_build_args).and_return({})
      allow(Kaiser::Config.config).to receive(:[]).with(:envnames).and_return(envs)

      obj = described_class.new
      allow(obj).to receive(:current_branch).and_return('master')

      allow(kaiserfile).to receive(:platform).and_return('linux/catcpu')

      expect(obj.build_cmd[0]).to eq 'docker build'
      expect(obj.build_cmd[1]).to eq '-t kaiser:meow-master'
      expect(obj.build_cmd[2]).to eq '-f /meow-dockerfile somedir'
      expect(obj.build_cmd[3]).to eq '--platform=linux/catcpu'
    end
  end
end

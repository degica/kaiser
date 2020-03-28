# frozen_string_literal: true

module Kaiser
  class GitSubmodule < Plugin
    def on_init
      `git submodule status`.lines.each do |line|
        # The git-submodule man page says uninitialized submodules are prefixed with a -
        # but I found this unreliable. While testing I pressed Control-C in the middle of
        # the update command so some submodule would be initialized and others wouldn't.
        # After that, the status command had removed the - for every submodule.
        # Therefore we just check if there's files in the directory instead.
        dir = line.strip.split(' ')[1]
        if !Dir.exist?(dir) || Dir.empty?(dir) # rubocop:disable Style/Next
          puts "Found uninitialized git submodule '#{dir}'"
          puts "please run 'git submodule update --init --recursive'"
          exit 1
        end
      end
    end
  end
end

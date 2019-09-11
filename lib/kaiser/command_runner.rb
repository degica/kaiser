# frozen_string_literal: true

# This is the command runner
module Kaiser
  # Make running easy
  class CommandRunner
    def self.run(out, cmd)
      out.puts "> #{cmd}"
      CommandRunner.new(out, cmd).run_command
    end

    def initialize(out, cmd)
      @out = out
      @cmd = cmd.tr "\n", ' '
    end

    def print_and_return_status(status = 0)
      @out.puts "$? = #{status}"
      @out.flush
      status
    end

    def print_lines(lines)
      lines.each do |line|
        @out.print line
        @out.flush
      end
    end

    def run_command
      PTY.spawn("#{@cmd} 2>&1") do |stdout, _stdin, _pid|
        print_lines(stdout)
      end
      print_and_return_status
    rescue Errno::EIO
      print_and_return_status
    rescue PTY::ChildExited => e
      print_and_return_status(e.status)
    end
  end
end

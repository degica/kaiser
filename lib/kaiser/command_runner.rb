# frozen_string_literal: true

require 'English'

# This is the command runner
module Kaiser
  # Make running easy
  class CommandRunner
    def self.run(out, cmd, &block)
      out.puts "> #{cmd}"
      CommandRunner.new(out, cmd).run_command(&block)
    end

    def self.run!(out, cmd, &block)
      status = run(out, cmd, &block)
      raise Kaiser::CmdError.new(cmd, status) if status.to_s != '0'
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
        yield line.chomp if block_given?
      end
    rescue Errno::EIO
      # Happens when `lines` stream is closed
    end

    def run_command(&block)
      PTY.spawn("#{@cmd} 2>&1") do |stdout, _stdin, pid|
        print_lines(stdout, &block)
        Process.wait(pid)
      end
      print_and_return_status $CHILD_STATUS.exitstatus
    rescue PTY::ChildExited => e
      print_and_return_status(e.status)
    end
  end
end

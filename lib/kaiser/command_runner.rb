# frozen_string_literal: true

require 'pty'
require 'English'

module Kaiser
  # This is the command runner
  # it abstracts away the complicated syntax required to deal with
  # PTY and to pass the lines programmatically to the host application
  # as well as to capture the return code at the end.
  class CommandRunner
    def self.run(out, cmd, env_vars: {}, &block)
      out.puts "> #{cmd}"
      CommandRunner.new(out, cmd, env_vars).run_command(&block)
    end

    def self.run!(out, cmd, env_vars: {}, &block)
      status = run(out, cmd, env_vars: env_vars, &block)
      raise Kaiser::CmdError.new(cmd, status) if status.to_s != '0'
    end

    def initialize(out, cmd, env_vars)
      @out = out
      @cmd = cmd.tr "\n", ' '
      @env_vars = env_vars
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
      PTY.spawn(@env_vars, "#{@cmd} 2>&1") do |stdout, _stdin, pid|
        print_lines(stdout, &block)
        Process.wait(pid)
      end
      print_and_return_status $CHILD_STATUS.exitstatus
    rescue PTY::ChildExited => e
      print_and_return_status(e.status)
    end
  end
end

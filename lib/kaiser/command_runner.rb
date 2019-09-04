require 'English'

# This is the command runner
module Kaiser
  # Make running easy
  class CommandRunner
    class Error < StandardError
    end

    def self.run(out, cmd)
      out.puts "> #{cmd}"
      CommandRunner.new(out, cmd).run_command
    end

    def self.run!(out, cmd)
      status = run(out, cmd)
      raise Error, "ERROR\n#{command}\n- exited with code #{status}" if status.to_s != '0'
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
    rescue Errno::EIO # rubocop:disable Lint/HandleExceptions
    end

    def run_command
      PTY.spawn("#{@cmd} 2>&1") do |stdout, _stdin, pid|
        print_lines(stdout)
        Process.wait(pid)
      end
      print_and_return_status $CHILD_STATUS.exitstatus
    rescue PTY::ChildExited => ex
      print_and_return_status(ex.status)
    end
  end
end

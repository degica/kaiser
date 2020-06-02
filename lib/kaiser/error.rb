# frozen_string_literal: true

module Kaiser
  # Base class for Kaiser-related errors.
  class Error < StandardError
  end

  # Raised when a command exits with non-zero exit status.
  class CmdError < Error
    def initialize(cmd, status)
      super "ERROR\n#{cmd}\n- exited with code #{status}"
    end
  end
end

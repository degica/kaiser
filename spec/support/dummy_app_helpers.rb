# frozen_string_literal: true

require 'open3'

module DummyAppHelpers
  # Run a command with Kaiser
  def run_command(args)
    output = Open3.popen3("#{Dir.pwd}/exe/kaiser #{args}")
    [output[1].read, output[2].read].join
  end

  # Path to the dummy application
  def dummy_app
    @dummy_app
  end

  #
  # Setup and teardown
  #

  def setup_dummy_app
    random_string = SecureRandom.hex.chars.first(4).join
    @dummy_app = File.expand_path File.join(__dir__, "../dummy-#{random_string}")
    FileUtils.rm_r dummy_app if File.exist?(dummy_app)
    FileUtils.mkdir_p dummy_app
  end

  def teardown_dummy_app
    FileUtils.rm_r dummy_app
    @dummy_app = nil
  end

  # Create a file inside the dummy application
  def create_file(file_name, contents)
    full_path = File.expand_path(File.join(dummy_app, file_name))

    dir = full_path.split('/')
    dir.pop
    FileUtils.mkdir_p(dir.join('/'))

    File.open(full_path, 'w') { |f| f.write contents }
  end
end

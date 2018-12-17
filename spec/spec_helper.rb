require 'bundler/setup'
require 'kaiser'
require 'factory_bot'
require 'aruba/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ArubaDoubles
  config.include Aruba::Api

  config.before :each do
    Aruba::RSpec.setup
    setup_aruba
  end

  config.before :each do |example|
    fixture_dir = example.metadata[:fixture_dir]
    if fixture_dir
      subpath = example.description.downcase.gsub(/[^0-9a-z]+/, '_')
      path = "#{Dir.pwd}/spec/fixtures/#{fixture_dir}/#{subpath}"
      if Dir.exist?(path)
        copy path, 'app'
      else
        create_directory 'app'
        warn "path #{path.inspect} not found"
      end
    end
  end

  config.after do |example|
    remove 'app' if example.metadata[:fixture_dir]
  end

  config.after :each do
    Aruba::RSpec.teardown
  end
end

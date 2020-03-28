# frozen_string_literal: true

require 'kaiser/plugin'

RSpec.describe Kaiser::Plugin do
  it 'loads plugin classes correctly' do
    class Dummy101And202Test < Kaiser::Plugin; end
    class DummyTest101 < Kaiser::Plugin; end
    class Dummy < Kaiser::Plugin; end

    expect(Kaiser::Plugin.loaded?(:dummy_101_and_202_test)).to be_truthy
    expect(Kaiser::Plugin.loaded?(:dummy_test_101)).to be_truthy
    expect(Kaiser::Plugin.loaded?(:dummy)).to be_truthy
    expect(Kaiser::Plugin.loaded?(:not_a_plugin)).to be_falsey
  end
end

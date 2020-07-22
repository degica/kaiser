# frozen_string_literal: true

require 'kaiser/service'

RSpec.describe Kaiser::Service do
  it 'has image' do
    s = Kaiser::Service.new('meow', 'santa' => { image: 'np/santa:lol' })

    expect(s.image).to eq 'np/santa:lol'
  end

  it 'has shared_name' do
    s = Kaiser::Service.new('meow', 'santa' => { image: 'np/santa:lol' })

    expect(s.shared_name).to eq 'meow-santa'
  end

  it 'has name' do
    s = Kaiser::Service.new('meow', 'santa' => { image: 'np/santa:lol' })

    expect(s.name).to eq 'santa'
  end
end

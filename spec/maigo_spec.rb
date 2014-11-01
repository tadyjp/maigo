# encoding: utf-8

require 'spec_helper'

describe Maigo do
  it 'has a version number' do
    expect(Maigo::VERSION).not_to be nil
  end

  it '#find_missing_outlets' do
    dir = File.expand_path('../MissingOutlet', __FILE__)
    missing_controllers, missing_outlets = Maigo.find_missing_outlets(dir)
    expect(missing_controllers.size).to eq(0)
    expect(missing_outlets.size).to eq(1)
  end
end

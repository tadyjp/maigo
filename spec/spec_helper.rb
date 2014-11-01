$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'maigo'

require 'coveralls'
Coveralls.wear!

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$:.unshift File.expand_path("../../lib", __FILE__)
$:.unshift File.expand_path("../../test", __FILE__)

ENV['EXERCISM_ENV'] = 'test'

gem 'minitest'; require 'minitest/autorun'
require 'minitest/pride'

require 'exercism'

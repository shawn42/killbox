$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'config'))
require 'environment'
require GAMEBOX_PATH + 'spec/helper'

RSpec.configure do |config|
  config.mock_with :mocha
end

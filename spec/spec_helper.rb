$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'config'))
require 'environment'
require GAMEBOX_PATH + 'spec/helper'

RSpec.configure do |config|
  config.mock_with :mocha
end

class Numeric
  def ish(acceptable_delta=0.001)
    ApproximateValue.new self, acceptable_delta
  end
end

class ApproximateValue
  def initialize(me, acceptable_delta)
    @me = me
    @acceptable_delta = acceptable_delta
  end

  def ==(other)
    (other - @me).abs < @acceptable_delta
  end

  def to_s
    "within #{@acceptable_delta} of #{@me}"
  end
end


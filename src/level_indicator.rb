class LevelIndicator
  attr_accessor :world, :level

  def initialize(args)
    @world, @level = args.values_at :world, :level
  end

  def to_s
    "#{world} - #{level}"
  end

end


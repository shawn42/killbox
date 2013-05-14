class ComputerPlayer
  attr_accessor :player
  def initialize(player)
    @player = player
    @input = ComputerInput.new @player
    @player.instance_variable_set('@input_mapper', @input)
    @turn = 0
  end

  def take_turn(time)
    @turn += 1
    if @turn % 480 == 0
      @input.shoot
    end
    if @turn % 80 == 0
      @input.shoot
    end

    if @turn % 500 < 100
      @input.charging_jump = true
    else
      @input.charging_jump = false
    end

    if @turn % 200 > 100
      @input.walk_right = false
      @input.walk_left = true
    else
      @input.walk_right = true
      @input.walk_left = false
    end
  end
end


class ComputerInput
  extend Publisher
  can_fire_anything

  def initialize(player)
    @old_input = player.input
  end

  def emit(*args, &blk)
    @old_input.send :fire, *args, &blk
  end

  # TURD
  def unsubscribe_all(*args)
    @old_input.unsubscribe_all *args
  end

  attr_accessor :charging_jump, :walk_left, :walk_right, 
    :charging_bomb, :look_left, :look_up, :look_down, :look_right

  def shoot
    emit :shoot
  end

  def charging_jump?
    @charging_jump
  end
  def charging_bomb?
    @charging_bomb
  end
  def walk_left?
    @walk_left
  end
  def walk_right?
    @walk_right
  end
  def look_up?
    @look_up
  end
  def look_down?
    @look_down
  end
  def look_left?
    @look_left
  end
  def look_right?
    @look_right
  end
end

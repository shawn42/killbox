module GameLogic
  def reset_timer
    session.level_time_remain = 360
  end

  def level_time_tick_down(amt)
    session.level_time_remain -= amt
    session.level_time_remain = 0 if session.level_time_remain < 0
    session.level_time_remain 
  end

  def kill_player
    session.player.lives -= 1
  end

  def game_over?
    session.player.lives <= 0
  end

  def peek_next_level
    li = session.level_indicator
    level = li.level
    world = li.world

    if level >= 3 
      world += 1
      level = 1
    else
      level += 1
    end

    return LevelIndicator.new(:world => world, :level => level)
  end

  def go_next_level
    session.level_indicator = peek_next_level
  end

  def current_level
    session.level_indicator
  end

  def game_won?
    return session.level_indicator.world >= 3
  end

end

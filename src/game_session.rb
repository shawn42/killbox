module GameSession
  def init_session
    player = Player.new
    player.id = 1
    player.name = "Foxy"
    player.character = :foxy
    player.lives = 3
    player.points = 0
    # player.jewels = 0

    state = State.new
    state.level_indicator = LevelIndicator.new(:world => 1, :level => 1)
    state.level_time_remain = 0

    state.player = player

    backstage[:game_session] = state
  end

  def session
    backstage[:game_session]
  end


  class State
    include Kvo
    kvo_attr_accessor :level_indicator, :player, :level_time_remain
  end

  class Player
    include Kvo
    kvo_attr_accessor :id, :name, :character, :points, :lives#, :jewels
  end

end

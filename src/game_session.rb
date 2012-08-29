module GameSession
  def init_session
    player = Player.new
    player.id = 1
    player.name = "Foxy"
    player.character = :foxy
    player.points = 0

    state = State.new

    state.player = player

    backstage[:game_session] = state
  end

  def session
    backstage[:game_session]
  end


  class State
    include Kvo
    kvo_attr_accessor :level, :player
  end

  class Player
    include Kvo
    kvo_attr_accessor :id, :name, :character, :points
  end

end

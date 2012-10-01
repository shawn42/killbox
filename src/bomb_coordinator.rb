class BombCoordinator
  BLAST_RADIUS = 100

  def initialize
    @active_bombs = []
    @explosion_listeners = []
  end

  def register_bomb(bomb)
    @active_bombs << bomb
    bomb.when :boom do
      unregister_bomb bomb
      x, y = bomb.x, bomb.y
      @explosion_listeners.each do |target|
        distance = Math.sqrt((x-target.x)**2 + (y-target.y)**2)

        if distance < BLAST_RADIUS
          target.react_to :esplode, bomb, distance
        end
      end
    end
  end

  def register_bombable(bombable)
    @explosion_listeners << bombable
  end

  def unregister_bombable(bombable)
    @explosion_listeners.delete bombable
  end

  def unregister_bomb(bomb)
    @active_bombs.delete bomb
  end

end

class BombCoordinator

  attr_accessor :active_bombs, :explosion_listeners
  def initialize
    @active_bombs = []
    @explosion_listeners = Hash.new { 0 }
  end

  def register_bomb(bomb)
    @active_bombs << bomb
    bomb.when :boom do
      unregister_bomb bomb
      @explosion_listeners.each do |target, count|
        distance = (vec2(target.x, target.y) - vec2(bomb.x, bomb.y)).magnitude

        if distance < bomb.radius
          target.react_to :esplode, bomb, distance
        end
      end
    end
  end

  def register_bombable(bombable)
    @explosion_listeners[bombable] += 1
  end

  def unregister_bombable(bombable)
    @explosion_listeners[bombable] -= 1
    @explosion_listeners.delete bombable if @explosion_listeners[bombable] == 0
  end

  def unregister_bomb(bomb)
    @active_bombs.delete bomb
  end

end

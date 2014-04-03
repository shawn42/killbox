class BombCoordinator
  construct_with :timer_manager

  attr_accessor :active_bombs, :explosion_listeners
  def initialize
    @active_bombs = []
    @explosion_listeners = Hash.new { 0 }
  end

  def register_bomb(bomb)
    @active_bombs << bomb
    bomb.when :boom do
      unregister_bomb bomb
      esplode_listeners = []
      disoriented_listeners = []

      @explosion_listeners.each do |target, count|
        if target != bomb and target.alive? and bomb.alive?
          distance = (target.position - bomb.position).magnitude

          if distance < bomb.radius * 4
            disoriented_listeners << {target: target, bomb: bomb, distance: distance}

            if distance < bomb.radius
              esplode_listeners << {target: target, bomb: bomb, distance: distance}
            end
          end
        end
      end

      disoriented_listeners.each do |opts|
        target = opts[:target]
        distance = opts[:distance]
        unless timer_manager.timer("#{target.object_id}_disorient")
          timer_manager.add_timer "#{target.object_id}_disorient", distance/2, false do
            target.react_to :disoriented, opts[:bomb], distance
          end
        end
      end

      esplode_listeners.each do |opts|
        target = opts[:target]
        distance = opts[:distance]
        unless timer_manager.timer("#{target.object_id}_esplode")
          timer_manager.add_timer "#{target.object_id}_esplode", distance, false do
            target.react_to :esplode, opts[:bomb], distance
          end
        end
      end

    end
  end

  def register_bombable(bombable)
    @explosion_listeners[bombable] += 1
  end

  def unregister_bombable(bombable)
    @explosion_listeners[bombable] -= 1
    @explosion_listeners.delete bombable if @explosion_listeners.has_key?(bombable) && 
      @explosion_listeners[bombable] == 0
  end

  def unregister_bomb(bomb)
    @active_bombs.delete bomb
  end

end

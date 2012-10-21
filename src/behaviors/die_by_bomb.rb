define_behavior :die_by_bomb do
  requires :bomb_coordinator, :stage
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      log "UG.. I died"
      if distance < (bomb.radius * 0.666)
        blast_vel = vec2(actor.x, actor.y) - vec2(bomb.x, bomb.y)
        actor.react_to :gibify, force: (blast_vel * 0.2)
        actor.remove 
      end
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

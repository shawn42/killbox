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
        actor.remove 
        30.times do
          vel = vec2(0.5,0).rotate!(degrees_to_radians(rand(359))) * rand(4)
          blast_vel = vec2(actor.x, actor.y) - vec2(bomb.x, bomb.y)
          stage.create_actor :gib, x: actor.x, y: actor.y, vel: vel + (blast_vel * 0.2), map: actor.map, size: rand(4)
        end
      end
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

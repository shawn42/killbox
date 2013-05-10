define_behavior :die_by_bomb do
  requires :bomb_coordinator, :stage, :score_keeper
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      log "UG.. I died"
      if distance < (bomb.radius * 0.666)
        blast_vel = (vec2(actor.x, actor.y) - vec2(bomb.x, bomb.y))

        blast_vel.magnitude = 130 / blast_vel.magnitude
        actor.react_to :gibify, force: blast_vel
        actor.remove 

        score_keeper.player_score(bomb.player) unless bomb.player == actor
      end
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

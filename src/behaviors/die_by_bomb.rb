define_behavior :die_by_bomb do
  requires :bomb_coordinator, :stage, :score_keeper, :map_inspector
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :esplode
  end

  remove do
    bomb_coordinator.unregister_bombable actor
  end

  helpers do
    def esplode(bomb, distance)
      if distance < (bomb.radius * 0.666) && map_inspector.line_of_sight?(actor, bomb)
        blast_vel = (vec2(actor.x, actor.y) - vec2(bomb.x, bomb.y))
        delay = blast_vel.magnitude * 2
        blast_vel.magnitude = 130 / blast_vel.magnitude

        actor.react_to :gibify, force: blast_vel
        actor.remove 
        score_keeper.player_score(bomb.player) unless bomb.player == actor
      end
    end

  end
end

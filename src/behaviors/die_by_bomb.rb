define_behavior :die_by_bomb do
  requires :bomb_coordinator, :stage, :score_keeper, :timer_manager
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      if distance < (bomb.radius * 0.666)
        blast_vel = (vec2(actor.x, actor.y) - vec2(bomb.x, bomb.y))
        delay = blast_vel.magnitude * 4
        blast_vel.magnitude = 130 / blast_vel.magnitude

        timer_manager.add_timer die_timer_name, delay, false do
          actor.react_to :gibify, force: blast_vel
          actor.remove 
          score_keeper.player_score(bomb.player) unless bomb.player == actor
        end
      end
    end

    def die_timer_name; "die_timer_#{object_id}"; end
    def remove
      bomb_coordinator.unregister_bombable actor
      timer_manager.remove_timer die_timer_name
    end

  end
end

define_behavior :die_by_sword do
  requires :sword_coordinator, :stage, :score_keeper
  setup do
    sword_coordinator.register_sliceable actor

    reacts_with :remove, :sliced
  end

  helpers do
    def sliced(sword, arc_angle)
      log "UG.. you stabbed me"
      # TODO need to track some sense of swung < N ms ago so I'm still swinging
      log "TODO parry"

      sword_vel = (actor.position - sword.position).unit
      if actor.action == :slice
        sword.vel -= sword_vel * 10
        actor.vel += sword_vel * 10
      else
        actor.react_to :play_sound, :death
        actor.react_to :gibify, force: sword_vel * 4
        score_keeper.player_score(sword)
        actor.remove
      end
    end

    def remove
      sword_coordinator.unregister_sliceable actor
    end

  end
end

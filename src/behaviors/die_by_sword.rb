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

      actor.react_to :play_sound, :death
      sword_vel = vec2(actor.x, actor.y) - vec2(sword.x, sword.y)
      actor.react_to :gibify, force: (sword_vel * 0.2)
      score_keeper.player_score(sword)
      actor.remove
    end

    def remove
      sword_coordinator.unregister_sliceable actor
    end

  end
end

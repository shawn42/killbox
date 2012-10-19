define_behavior :die_by_sword do
  requires :sword_coordinator, :stage
  setup do
    sword_coordinator.register_sliceable actor

    reacts_with :remove, :sliced
  end

  helpers do
    def sliced(sword)
      log "UG.. you stabbed me"
      log "TODO parry"
      actor.react_to :play_sound, :death
      actor.remove

      # TODO gib generator?
      20.times do
        vel = vec2(0.5,0).rotate!(degrees_to_radians(rand(359))) * rand(3)
        stage.create_actor :gib, x: actor.x, y: actor.y, vel: vel, map: actor.map, size: rand(4)
      end

    end

    def remove
      sword_coordinator.unregister_sliceable actor
    end

  end
end

define_behavior :die_by_bullet do
  requires :bullet_coordinator, :stage
  setup do
    bullet_coordinator.register_shootable actor

    reacts_with :remove, :shot
  end

  helpers do
    def shot(bullet)
      log "UG.. you shot me"
      actor.react_to :play_sound, :death
      actor.remove

      actor.react_to :gibify, force: (bullet.vel * 0.2)

      # stage.create_actor :splat, x: actor.x, y: actor.y, view: :graphical_actor_view

    end

    def remove
      bullet_coordinator.unregister_shootable actor
    end

  end
end

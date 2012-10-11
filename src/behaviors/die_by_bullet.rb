define_behavior :die_by_bullet do
  requires :bullet_coordinator
  setup do
    bullet_coordinator.register_shootable actor

    reacts_with :remove, :shot
  end

  helpers do
    def shot(bullet)
      log "UG.. you shot me"
      actor.react_to :play_sound, :death
      actor.remove
      # TODO GIBS!!
    end

    def remove
      bullet_coordinator.unregister_shootable actor
    end

  end
end

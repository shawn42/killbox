define_behavior :absorb_bullet do
  requires :bullet_coordinator
  setup do
    bullet_coordinator.register_shootable actor

    reacts_with :remove, :shot
  end

  helpers do
    def shot(bullet)
      log "my shield ate your bullet"
      actor.react_to :play_sound, :death
      bullet.remove
    end

    def remove
      bullet_coordinator.unregister_shootable actor
    end

  end
end

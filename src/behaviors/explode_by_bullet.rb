define_behavior :explode_by_bullet do
  requires :bullet_coordinator
  setup do
    bullet_coordinator.register_shootable actor

    reacts_with :remove, :shot
  end

  helpers do
    def shot(bullet)
      actor.react_to :play_sound, :bomb
      actor.emit :boom
      bullet.remove
      actor.remove
    end

    def remove
      bullet_coordinator.unregister_shootable actor
    end

  end
end

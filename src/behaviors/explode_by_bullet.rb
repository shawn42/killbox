define_behavior :explode_by_bullet do
  requires :bullet_coordinator
  setup do
    bullet_coordinator.register_shootable actor

    reacts_with :shot
  end

  remove do
    bullet_coordinator.unregister_shootable actor
  end

  helpers do
    def shot(bullet)
      actor.react_to :play_sound, :bomb
      actor.player = bullet.player
      actor.emit :boom
      bullet.remove
      actor.remove
    end


  end
end

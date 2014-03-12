define_behavior :die_by_bullet do
  requires :bullet_coordinator, :stage, :backstage, :score_keeper

  setup do
    bullet_coordinator.register_shootable actor

    reacts_with :shot
  end

  remove do
    bullet_coordinator.unregister_shootable actor
  end

  helpers do
    def shot(bullet)
      actor.react_to :play_sound, :death
      actor.remove

      actor.react_to :gibify, force: (bullet.vel * 0.2)
      score_keeper.player_score(bullet.player) unless actor == bullet.player
    end

  end
end

define_behavior :die_by_bomb do
  requires :bomb_coordinator
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      log "UG.. I died"
      actor.remove
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

define_behavior :blasted_by_bomb do
  requires :bomb_coordinator
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      # TODO only apply if below feet
      forceV = vec2(bomb.x, bomb.y) - vec2(actor.x, actor.y)
      force = (1-(distance / bomb.force)) * bomb.radius
      forceV.scale! force
      actor.on_ground = false
      actor.vel += forceV
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

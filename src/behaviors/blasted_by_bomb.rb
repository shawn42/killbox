define_behavior :blasted_by_bomb do
  requires :bomb_coordinator
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      # TODO only apply if below feet
      forceV =  vec2(actor.x, actor.y) - vec2(bomb.x, bomb.y)
      
      force = (1-(distance / bomb.radius)) * bomb.force
      forceV.scale! force
      actor.vel += forceV
      # TODO eewww need to keep bombs from blasting you through the floor
      actor.vel.magnitude = 12 if actor.vel.magnitude > 12
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

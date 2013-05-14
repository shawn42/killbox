define_behavior :blasted_by_bomb do
  requires :bomb_coordinator, :map_inspector
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      # TODO only apply if below feet
      if map_inspector.line_of_sight?(actor, bomb)
        blast_vel = (actor.position - bomb.position).unit * 15
        actor.vel += blast_vel

        # TODO eewww need to keep bombs from blasting you through the floor
        actor.vel.magnitude = 12 if actor.vel.magnitude > 12
      end
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

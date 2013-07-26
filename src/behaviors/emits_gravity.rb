define_behavior :emits_gravity do
  requires :black_hole_coordinator
  requires_behaviors :positioned

  setup do
    actor.has_attributes gravity_range: 150, force: 0.06
    black_hole_coordinator.register_black_hole actor

    reacts_with :pull
  end

  remove do
    black_hole_coordinator.unregister_black_hole actor
  end

  helpers do

    def pull(pullable)
      # if map_inspector.line_of_sight?(actor, bomb)
      # TODO use director in black_hole_coordinator
      diff = actor.position - pullable.position
      pull_vel = diff.unit * (actor.force / (diff.magnitude.to_f / actor.gravity_range ))
      pullable.vel += pull_vel

      # TODO eeewwww
      pullable.vel.magnitude = 12 if pullable.vel.magnitude > 12
    end
  end
end

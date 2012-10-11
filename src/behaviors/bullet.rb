define_behavior :bullet do

  requires :director, :stage
  requires_behaviors :positioned
  setup do
    actor.has_attributes vel: vec2(0,0)

    # always emits the event, but will have nil collisions if we didn't collide
    # with anything
    actor.when :tile_collisions do |collisions|
      if collisions
        actor.remove
      else
        actor.emit :bullet_moved
      end
    end
  end

end

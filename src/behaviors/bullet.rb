define_behavior :bullet do

  requires :director, :stage, :timer_manager
  requires_behaviors :positioned
  setup do
    actor.has_attributes vel: vec2(0,0), armed: false

    # bandaid for shooting self..
    timer_manager.add_timer "#{object_id}:self:arm", 4_000, false do
      actor.armed = true
    end
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

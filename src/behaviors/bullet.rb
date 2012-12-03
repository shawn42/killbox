define_behavior :bullet do

  requires :director, :stage, :timer_manager
  requires_behaviors :positioned
  setup do
    actor.has_attributes vel: vec2(0,0), armed: false

    timer_manager.add_timer timer_name, 3_500, false do
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

    reacts_with :remove
  end

  helpers do
    def timer_name
      "#{object_id}:self:arm"
    end

    def remove
      actor.unsubscribe_all self
      timer_manager.remove_timer timer_name
    end
  end

end

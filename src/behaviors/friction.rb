define_behavior :friction do
  requires :director
  setup do
    actor.has_attributes friction: opts[:amount]
    director.when :update do |time_millis, time_secs|
      # TODO only if on the ground?
      if actor.vel.magnitude > 0.001
        # apply friction per 5 ms
        (time_millis / 5.0).ceil.times do
          actor.vel.magnitude *= (1 - [actor.friction, 1].min)
        end
        if (!actor.move_left? && !actor.move_right?) && actor.accel.magnitude < (1 * time_secs)
          # stop short
          actor.vel = vec2(0,0) if actor.vel.magnitude < 0.3
        end
      end

    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
end

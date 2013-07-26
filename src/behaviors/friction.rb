define_behavior :friction do
  requires :director
  setup do
    actor.has_attributes friction: opts[:amount]
    director.when :first do |time_millis, time_secs|

      if actor.on_ground? and actor.vel.magnitude > 0.001
        time_to_stop_in_ms = 100

        friction = 1 - min(actor.friction, 1)
        velocity_removal_percentage = time_millis.to_f / time_to_stop_in_ms

        friction_force = -(actor.vel * velocity_removal_percentage * friction)

        actor.accel += friction_force
      end
    end
  end

  remove do
    director.unsubscribe_all self
  end

  helpers do
    include MinMaxHelpers

  end
end

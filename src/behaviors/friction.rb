define_behavior :friction do
  requires :director
  setup do
    actor.has_attributes friction: opts[:amount]
    director.when :update do |time_millis, time_secs|
       # TODO only if on the ground?
      if actor.accel.magnitude > 0.001
        actor.accel.magnitude *= (1-(time_secs*actor.friction))
      else
        actor.accel = vec2(0,0)
      end
      
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
end

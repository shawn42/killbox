define_behavior :friction do
  requires :director
  setup do
    actor.has_attributes friction: opts[:amount]
    director.when :update do |time_millis, time_secs|
       # TODO only if on the ground?

      puts "FRICTION"
      # if actor.vel.magnitude > 0.001
      #   if actor.vel.magnitude > 1
      #     friction = actor.vel.unit.reverse! * (1 - [time_secs*actor.friction, 1].min)
      #   else
      #     friction = actor.vel.reverse! * (1 - [time_secs*actor.friction, 1].min)
      #   end
      #   puts "MOAR FRICTION #{friction}"
      #   actor.accel += friction
      # else
      #   actor.vel = vec2(0,0)
      # end
      
      if actor.vel.magnitude > 0.001
        actor.vel.magnitude *= (1 - [time_secs*actor.friction*0.5, 1].min)
      else
        actor.vel = vec2(0,0)
      end
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
end

define_behavior :accelerator do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: vec2(0,0),
                         vel: vec2(0,0)
                        
    director.when :before do |time, time_secs|
      input = actor.input

      # this should live in its own behavior to modify accel
      # vvvvvvvvvvvvvvvv
      speed = actor.speed

      if input.walk_right? && actor.on_ground?
        force = actor.ground_normal.rotate(Math::HALF_PI) * speed * time_secs
        actor.accel += force 
        actor.action = :walking_right
      elsif input.walk_left? && actor.on_ground?
        force = actor.ground_normal.rotate(-Math::HALF_PI) * speed * time_secs
        actor.accel += force
        actor.action = :walking_left
      else
        actor.action = :idle if actor.on_ground?
      end
      # ^^^^^^^^^^^^^^^

      actor.vel += actor.accel

      # TODO this should probably live in jump behavior
      if !actor.on_ground?
        actor.action = :jumping 
      end

      if (!input.walk_right? && !input.walk_right?)
        # stop short
        actor.vel = vec2(0,0) if actor.vel.magnitude < 0.3
      end
    end

    director.when :last do |time, time_secs|
      actor.accel = vec2(0,0)
    end

    reacts_with :remove
  end

  helpers do
    include MinMaxHelpers
    def remove
      actor.vel = vec2(0,0) if actor.on_ground
      director.unsubscribe_all self
      actor.input.unsubscribe_all self
    end
  end
end

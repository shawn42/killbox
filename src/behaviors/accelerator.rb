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

      if actor.on_ground?
        if input.walk_right?
          force = actor.ground_normal.rotate(Math::HALF_PI) * speed * time_secs
          actor.accel += force 
        elsif input.walk_left?
          force = actor.ground_normal.rotate(-Math::HALF_PI) * speed * time_secs
          actor.accel += force
        end
      end

      # ^^^^^^^^^^^^^^^

      # TODO XXX animation: need a state machine of some sort here
      unless actor.action == :slice
        if actor.on_ground?
          if input.walk_right?
            actor.action = :walking_right
          elsif input.walk_left?
            actor.action = :walking_left
          else
            actor.action = :idle
          end
        else
          actor.action = :jumping 
        end
      end

      actor.vel += actor.accel

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

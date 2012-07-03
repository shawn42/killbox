define_behavior :accelerator do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: vec2(0,0),
                         max_speed: opts[:max_speed],
                         vel: vec2(0,0),
                         flip_h: false
                        
    director.when :first do |time, time_secs|
      if actor.move_right?
        actor.accel += vec2(actor.speed * time_secs, 0)
        actor.flip_h = false
      elsif actor.move_left?
        actor.flip_h = true
        actor.accel += vec2(-actor.speed * time_secs, 0)
      end

      actor.vel += actor.accel

      if (0.0-actor.vel[1]).abs <= 0.1 && actor.action != :idle
        actor.action = :idle
      end
      
      if (actor.vel[0]) > 0.01
        actor.action = :walking_right unless actor.action == :walking_right
      elsif (actor.vel[0]) < -0.01
        actor.action = :walking_left unless actor.action == :walking_left
      end
      
      if actor.vel[1] < 0.05
        actor.action = :jumping unless actor.action == :jumping
      elsif actor.vel[1] > 0.1 && !actor.on_ground
        actor.action = :falling unless actor.action == :falling
      end
    end

    director.when :last do |time, time_secs|
      actor.accel = vec2(0,0)
    end

    director.when :before do |time, time_secs|
      actor.vel += actor.accel
      
      if actor.vel[1] < 0.05
        actor.action = :jumping unless actor.action == :jumping
      elsif actor.vel[1] > 0.1 && !actor.on_ground
        actor.action = :falling unless actor.action == :falling
      end
      actor.vel.magnitude = actor.max_speed if actor.vel.magnitude > actor.max_speed
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end

  helpers do
    include MinMaxHelpers
  end
end

define_behavior :accelerator do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         air_speed: opts[:air_speed],
                         accel: vec2(0,0),
                         max_speed: opts[:max_speed],
                         vel: vec2(0,0),
                         flip_h: false
                        
    director.when :before do |time, time_secs|
      speed = actor.on_ground ? actor.speed : actor.air_speed

      if actor.move_right? && actor.vel.x < (actor.max_speed / 3.0) && actor.on_ground?
        force = actor.ground_normal.rotate(Ftor::HALF_PI) * speed * time_secs
        actor.accel += force 
        actor.flip_h = false
      elsif actor.move_left? && actor.vel.x > -(actor.max_speed / 3.0) && actor.on_ground?
        force = actor.ground_normal.rotate(-Ftor::HALF_PI) * speed * time_secs
        actor.accel += force
        actor.flip_h = true
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
      # actor.action = :idle
    end

    director.when :before do |time, time_secs|
      actor.vel += actor.accel
      
      if actor.vel[1] < 0.05
        actor.action = :jumping unless actor.action == :jumping
      elsif actor.vel[1] > 0.1 && !actor.on_ground
        actor.action = :falling unless actor.action == :falling
      end

      actor.vel.magnitude = actor.max_speed if actor.vel.magnitude > actor.max_speed

      if (!actor.move_left? && !actor.move_right?) #&& actor.accel.magnitude < (1 * time_secs)
        # stop short
        actor.vel = vec2(0,0) if actor.vel.magnitude < 0.3
      end
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end

  helpers do
    include MinMaxHelpers
  end
end

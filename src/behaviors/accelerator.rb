define_behavior :accelerator do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         air_speed: opts[:air_speed],
                         accel: vec2(0,0),
                         max_speed: opts[:max_speed],
                         vel: vec2(0,0)
                        
    director.when :before do |time, time_secs|
      input = actor.input
      speed = actor.on_ground ? actor.speed : actor.air_speed

      
      if input.walk_right? && actor.vel.x < (actor.max_speed / 3.0) && actor.on_ground? && actor.ground_normal
        force = actor.ground_normal.rotate(Math::HALF_PI) * speed * time_secs
        actor.accel += force 
        actor.action = :walking_right unless actor.action == :walking_right
      elsif input.walk_left? && actor.vel.x > -(actor.max_speed / 3.0) && actor.on_ground? && actor.ground_normal
        force = actor.ground_normal.rotate(-Math::HALF_PI) * speed * time_secs
        actor.accel += force
        actor.action = :walking_left unless actor.action == :walking_left
      else
        actor.action = :idle if actor.on_ground? && actor.action != :idle
      end

      actor.vel += actor.accel
    end

    director.when :last do |time, time_secs|
      actor.accel = vec2(0,0)
    end

    director.when :before do |time, time_secs|
      input = actor.input
      actor.vel += actor.accel

      # TODO eeewww.. asphyxiate leaked in here  :(
      if !actor.on_ground && actor.action != :jumping && actor.action != :asphyxiate
        actor.action = :jumping 
      end
      actor.vel.magnitude = actor.max_speed if actor.vel.magnitude > actor.max_speed

      if (!input.walk_right? && !input.walk_right?) #&& actor.accel.magnitude < (1 * time_secs)
        # stop short
        actor.vel = vec2(0,0) if actor.vel.magnitude < 0.3
      end
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

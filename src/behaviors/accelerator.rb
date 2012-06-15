define_behavior :accelerator do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: vec2(0,0),
                         max_speed: opts[:max_speed],
                         vel: vec2(0,0),
                         jumping: false,
                         max_jump_force: 400,
                         jumping_force: 0
                        

    actor.when :hit_bottom do
      actor.jumping = false
    end

    director.when :update do |time, time_secs|

      # TODO performance of creating vecs here instead of modifying in place?
      if actor.move_right?
        actor.accel += vec2(actor.speed * time_secs, 0)
      elsif actor.move_left?
        actor.accel += vec2(-actor.speed * time_secs, 0)
      end

      # TODO should jumping be its own behavior?
      if actor.attempt_jump? && !actor.jumping
        actor.jumping_force = actor.max_jump_force
        actor.jumping = true
      end

      unless actor.jumping_force <= 0
        actor.accel.y -= actor.jumping_force * time_secs
        max = actor.max_jump_force
        jf = actor.jumping_force
        actor.jumping_force -= 9.0 * jf / max * time
      end

      actor.vel += actor.accel

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

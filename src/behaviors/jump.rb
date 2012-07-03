define_behavior :jump do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: vec2(0,0),
                         max_speed: opts[:max_speed],
                         vel: vec2(0,0),
                         max_jump_force: 400,
                         jumping_force: 0,
                         flip_h: false
                        
    director.when :first do |time, time_secs|

      if actor.attempt_jump? && actor.on_ground
        actor.jumping_force = actor.max_jump_force
        actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
      end

      unless (0-actor.jumping_force).abs <= 0.001
        actor.accel.y -= actor.jumping_force * time_secs
        max = actor.max_jump_force
        jf = actor.jumping_force
        actor.jumping_force -= 9.0 * jf / max * time
      end

      actor.when :hit_top do
        actor.jumping_force = 0
      end

    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end

end


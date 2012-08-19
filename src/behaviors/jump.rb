define_behavior :jump do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: vec2(0,0),
                         rotation_vel: 0,
                         power: opts[:power],
                         max_jump_power: 100,
                         min_jump_power: 30,
                         charging_jump: false
                        
    actor.has_attributes jump_power: actor.min_jump_power

    director.when :first do |time, time_secs|
      update_jump time_secs
    end

    actor.when :remove_me do
      remove 
    end

    reacts_with :remove
  end

  helpers do

    def update_jump(time_secs)
      if actor.charging_jump?
        actor.jump_power += actor.max_jump_power * time_secs * 3
        actor.jump_power = actor.max_jump_power if actor.jump_power > actor.max_jump_power
      else
        if actor.jump_power > actor.min_jump_power && actor.on_ground
          log "jumping!"
          # log "GROUND: #{actor.ground_normal}"
          if actor.ground_normal
            mod = actor.ground_normal * actor.power * time_secs * (actor.jump_power.to_f / actor.max_jump_power)
            actor.accel += mod
          end
          # log "MOD: #{mod}"
          # log "ACCEL: #{actor.accel}"
          actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
          actor.remove_behavior :gravity
          actor.on_ground = false
          actor.emit :jump

          # degrees
          # TODO look at direction we're facing and rotate backwards
          actor.rotation_vel += 45 * time_secs
        end

        actor.jump_power = actor.min_jump_power
      end
    end

    def remove
      director.unsubscribe_all self
    end
  end

end


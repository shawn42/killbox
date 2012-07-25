define_behavior :jump do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: vec2(0,0),
                         gravity: vec2(0,0),
                         anti_gravity_multiplier: opts[:anti_gravity_multiplier],
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
          actor.accel += -actor.gravity * actor.anti_gravity_multiplier * time_secs * (actor.jump_power.to_f / actor.max_jump_power)
          actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
        end
        actor.jump_power = actor.min_jump_power
      end
    end

    def remove
      director.unsubscribe_all self
    end
  end

end


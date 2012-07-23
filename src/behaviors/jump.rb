define_behavior :jump do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: vec2(0,0),
                         gravity: vec2(0,0),
                         anti_gravity_multiplier: opts[:anti_gravity_multiplier]
                        
    director.when :first do |time, time_secs|
      if actor.attempt_jump? && actor.on_ground
        actor.accel += -actor.gravity * actor.anti_gravity_multiplier * time_secs

        actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
      end
    end

    actor.when :remove_me do
      remove 
    end

    reacts_with :remove
  end

  helpers do
    def remove
      director.unsubscribe_all self
    end
  end

end


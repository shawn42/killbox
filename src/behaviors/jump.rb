# TODO
# jump need moar power!
define_behavior :jump do
  requires :director
  setup do
    actor.has_attributes accel:          vec2(0,0),
                         rotation_vel:   0,
                         jump_rotation:  opts[:rotational_power],
                         max_jump_power: 60,
                         min_jump_power: 10
                        
    actor.has_attributes jump_power: actor.min_jump_power

    director.when :first do |time, time_secs|
      update_jump time_secs
    end

    reacts_with :remove
  end

  helpers do
    include MinMaxHelpers

    def update_jump(time_secs)
      if actor.input.charging_jump? && actor.on_ground?
        actor.jump_power = min(actor.jump_power + actor.max_jump_power * time_secs * 1.5, actor.max_jump_power)
        remove_behavior :accelerator if actor.jump_power == actor.max_jump_power

      else
        add_behavior :accelerator if actor.jump_power == actor.max_jump_power

        if actor.jump_power > actor.min_jump_power && actor.on_ground
          if actor.ground_normal
            mod = actor.ground_normal * actor.jump_power * 0.05
            actor.accel += mod
          end
          actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
          actor.emit :jump
        end

        actor.jump_power = actor.min_jump_power
      end
    end

    def remove
      actor.jump_power = actor.min_jump_power
      director.unsubscribe_all self
    end
  end

end


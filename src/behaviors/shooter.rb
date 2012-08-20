define_behavior :shooter do
  requires :input_manager, :timer_manager
  setup do
    actor.has_attributes accel: vec2(0,0),
                         shot_power: opts[:shot_power],
                         shot_recharge_time: opts[:recharge_time],
                         can_shoot: true,
                         gun_direction: DIRECTIONS[:left]
                        
    # TODO abstract this into gamebox (controls or something)
    input_manager.reg :down, KbLeft do
      actor.gun_direction = DIRECTIONS[:left]
    end
    input_manager.reg :down, KbRight do
      actor.gun_direction = DIRECTIONS[:right]
    end
    input_manager.reg :down, KbUp do
      actor.gun_direction = DIRECTIONS[:up]
    end
    input_manager.reg :down, KbDown do
      actor.gun_direction = DIRECTIONS[:down]
    end

    input_manager.reg :down, KbSpace do
      if actor.can_shoot?
        actor.can_shoot = false
        actor.accel += actor.gun_direction.rotate(degrees_to_radians(actor.rotation)).dup.reverse! * actor.shot_power
        timer_manager.add_timer 'shot_recharge', actor.shot_recharge_time do
          actor.can_shoot = true
          timer_manager.remove_timer 'shot_recharge'
        end
      end
    end

    actor.when :remove_me do
      remove 
    end

    reacts_with :remove
  end

  helpers do
    DIRECTIONS = {
      left: vec2(-1,0),
      right: vec2(1,0),
      up: vec2(0,-1),
      down: vec2(0,1)
    }

    def remove
      input_manager.unsubscribe_all self
    end
  end

end


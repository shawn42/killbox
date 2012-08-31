define_behavior :shooter do
  requires :timer_manager, :stage
  setup do
    actor.has_attributes shot_power: opts[:shot_power],
                         kickback: opts[:kickback],
                         shot_recharge_time: opts[:recharge_time],
                         can_shoot: true,
                         gun_direction: shoot_directions[:right]
                        
    setup_gun_looking

    actor.input.when(:shoot) { shoot_if_able }

    reacts_with :remove
  end

  helpers do
    def shoot_directions 
      {
      left: vec2(-1,0),
      right: vec2(1,0),
      up: vec2(0,-1),
      down: vec2(0,1)
      }
    end

    def setup_gun_looking
      input = actor.input
      input.when :look_left do
        actor.gun_direction = shoot_directions[:left]
      end
      input.when :look_right do
        actor.gun_direction = shoot_directions[:right]
      end
      input.when :look_up do
        actor.gun_direction = shoot_directions[:up]
      end
      input.when :look_down do
        actor.gun_direction = shoot_directions[:down]
      end
    end

    def shoot_if_able
      if actor.can_shoot?
        actor.can_shoot = false
        rotated_gun_dir = actor.gun_direction.rotate(degrees_to_radians(actor.rotation))
        actor.accel += rotated_gun_dir.dup.reverse! * actor.kickback
        # seems strange, even though in physics terms we should add the
        # actor.vel
        shot_vel = (rotated_gun_dir*actor.shot_power) #+ actor.vel
        stage.create_actor :bullet, player: actor, x: actor.x, y: actor.y, map: actor.map, vel: shot_vel
        actor.react_to :play_sound, :shoot

        # TODO per Dustin: move this to where we apply the velocity
        unless actor.on_ground?
          gun_angle = actor.gun_direction.angle
          if gun_angle == 0
            actor.rotation_vel -= 0.3 
          elsif gun_angle == Math::PI
            actor.rotation_vel += 0.3 
          end
        end

        timer_name = "#{actor.object_id}:shot_recharge"
        timer_manager.add_timer timer_name, actor.shot_recharge_time do
          actor.can_shoot = true
          timer_manager.remove_timer timer_name
        end
      end
    end

    def remove
      timer_name = "#{actor.object_id}:shot_recharge"
      timer_manager.remove_timer 'shot_recharge'
    end
  end

end


define_behavior :shooter do
  requires :timer_manager, :stage, :bullet_coordinator
  setup do
    actor.has_attributes shot_power: opts[:shot_power],
                         kickback: opts[:kickback],
                         shot_recharge_time: opts[:recharge_time],
                         can_shoot: true,
                         gun_direction: shoot_directions[:right],
                         gun_tip: nil
                        
    actor.can_shoot = true
    setup_gun_looking
    update_gun_tip
    actor.when(:gun_direction_changed){ update_gun_tip }
    actor.when(:rotation_changed){ update_gun_tip }
    actor.when(:position_changed){ update_gun_tip }

    actor.input.when(:shoot) { shoot_if_able }
  end

  remove do
    timer_manager.remove_timer timer_name
    actor.can_shoot = false
    timer_manager.remove_timer 'shot_recharge'
    actor.input.unsubscribe_all(self)
    actor.unsubscribe_all(self)
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

    def update_gun_tip
      rotation = actor.do_or_do_not(:rotation) || 0
      rotated_gun_dir = actor.gun_direction.rotate(degrees_to_radians(rotation))
      rotated_gun_dir.magnitude = 22
      actor.gun_tip = rotated_gun_dir + actor.position
      # log ">> update_gun_tip: gun_tip: #{actor.gun_tip.inspect}"

      if ENV['DEBUG']
        # for debug drawing
        actor.has_attribute :shot_vel
        actor.shot_vel = shot_vel
      end
    end

    def shot_vel
      (actor.gun_tip - actor.position).unit * actor.shot_power
    end

    def shoot_if_able
      if actor.can_shoot?
        actor.can_shoot = false
        rotated_gun_dir = actor.gun_direction.rotate(degrees_to_radians(actor.rotation))

        # puts ">> shoot_if_able: gun_tip: #{actor.gun_tip.inspect}"
        bullet_pos = actor.position + ((actor.gun_tip - actor.position) * 1.9)
        bullet = stage.create_actor :bullet, player: actor, x: bullet_pos.x, y: bullet_pos.y, map: actor.map, vel: shot_vel
        bullet_coordinator.register_bullet bullet

        kickback = rotated_gun_dir.dup.reverse! * actor.kickback
        actor.accel += kickback
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

        timer_manager.add_timer timer_name, actor.shot_recharge_time, false do
          actor.can_shoot = true
          actor.react_to :play_sound, :reload
        end
      else
        actor.emit(:failed_to_shoot)
      end
    end

    def timer_name
      "#{actor.object_id}:shot_recharge"
    end

  end

end


# TODO
# too much velocity
# charge may be a little slow
define_behavior :bomber do
  requires :stage, :director, :bomb_coordinator
  setup do
    # lets start with infinite bombs, fixed vel
    actor.has_attributes bomb_charge: 0,
                         bombs_left: 5,
                         max_bomb_charge: 2,
                         was_charging_bomb: false,
                         bomb_kickback: opts[:kickback] || 0
                        
    director.when :first do |time, time_secs|
      update_bombing time_secs
    end
  end

  remove do
    actor.controller.unsubscribe_all self
    director.unsubscribe_all self
  end

  helpers do
    include MinMaxHelpers
    include Look

    def update_bombing(time_secs)
      input = actor.controller
      if actor.was_charging_bomb? && !input.charging_bomb?
        actor.was_charging_bomb = false

        if actor.bombs_left > 0
          if actor.on_ground? && input.look_down?
            plant_landmine
          else
            throw_bomb
          end
        end

      elsif input.charging_bomb?
        actor.bomb_charge += time_secs
        actor.bomb_charge = min(actor.max_bomb_charge, actor.bomb_charge)
        actor.was_charging_bomb = true
      end
    end

    def plant_landmine
      actor.bombs_left -= 1
      points = actor.collision_points[4..5]
      center_feet_location = vec2(points.map(&:x).average, points.map(&:y).average)
      mine = stage.create_actor :land_mine, player: actor, x: center_feet_location.x, y: center_feet_location.y, map: actor.map, rotation: actor.rotation

      bomb_coordinator.register_bomb mine
    end

    def throw_bomb
      actor.bombs_left -= 1
      percent = (actor.bomb_charge / actor.max_bomb_charge.to_f)
      power = 10 * percent

      # rotated_gun_dir = actor.gun_direction.rotate(degrees_to_radians(actor.rotation))
      bomb_vel = actor.vel + ((actor.gun_tip - actor.position).unit * power)

      bomb = stage.create_actor :bomb, player: actor, x: actor.x, y: actor.y, map: actor.map, vel: bomb_vel, rotation_vel: 2.4
      bomb_coordinator.register_bomb bomb

      actor.react_to :play_sound, :shoot

      # minimum kickback is 20 percent
      kickback = bomb_vel.unit.reverse! * (actor.bomb_kickback * max(0.2, percent))
      # log kickback
      actor.accel += kickback

      unless actor.on_ground?
        gun_angle = actor.gun_direction.angle
        if gun_angle == 0
          actor.rotation_vel -= 0.3
        elsif gun_angle == Math::PI
          actor.rotation_vel += 0.3
        end
      end
      actor.bomb_charge = 0
    end

  end

end


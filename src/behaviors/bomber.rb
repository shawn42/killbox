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
                         bomb_reticle: create_reticle,
                         reticle_vector: nil,
                         bomb_kickback: opts[:kickback] || 0
                        
    director.when :first do |time, time_secs|
      update_bombing time_secs if has_bombs_left?
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
      if released_charged_bomb?
        add_behavior :accelerator
        release_bomb
      elsif started_charging_bomb?
        remove_behavior :accelerator
        actor.vel = vec2(0,0) if actor.on_ground?
        charge_bomb time_secs
      elsif charging_bomb?
        actor.vel = vec2(0,0) if actor.on_ground?
        charge_bomb time_secs
      end
    end

    def create_reticle
      stage.create_actor :reticle, hide: true
    end

    def reset_reticle
      actor.bomb_reticle.react_to :hide
    end

    def update_reticle
      actor.bomb_reticle.react_to :show
      min_dist_from_actor = 10
      max_dist_from_actor = 40

      rotation = actor.do_or_do_not(:rotation) || 0
      dist_from_actor = min_dist_from_actor + 
        (max_dist_from_actor - min_dist_from_actor) * 
        (actor.bomb_charge / actor.max_bomb_charge.to_f)

      reticle_vector = (actor.look_vector * dist_from_actor).
        rotate(degrees_to_radians(rotation))

      actor.reticle_vector = reticle_vector

      actor.bomb_reticle.position = actor.position + actor.reticle_vector
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

      bomb_vel = actor.vel + (actor.reticle_vector.unit * power)
      bomb_pos = actor.position + bomb_vel
      bomb = stage.create_actor :bomb, player: actor, x: bomb_pos.x, y: bomb_pos.y, map: actor.map, vel: bomb_vel, rotation_vel: 2.4
      bomb_coordinator.register_bomb bomb

      actor.react_to :play_sound, :shoot

      # minimum kickback is 20 percent
      kickback = bomb_vel.unit.reverse! * (actor.bomb_kickback * max(0.2, percent))
      actor.accel += kickback

      unless actor.on_ground?
        angle = actor.reticle_vector.angle
        if angle == 0
          actor.rotation_vel -= 0.3
        elsif angle == Math::PI
          actor.rotation_vel += 0.3
        end
      end
      actor.bomb_charge = 0
    end

    def has_bombs_left?
      actor.bombs_left > 0
    end

    def planting_landmine?
      actor.on_ground? && actor.controller.look_down?
    end

    def released_charged_bomb?
      actor.was_charging_bomb? && !charging_bomb?
    end

    def started_charging_bomb?
      !actor.was_charging_bomb? && charging_bomb?
    end

    def charging_bomb?
      actor.controller.charging_bomb?
    end

    def release_bomb
      reset_reticle
      actor.was_charging_bomb = false
      planting_landmine? ? plant_landmine : throw_bomb
    end

    def charge_bomb(time_secs)
      update_reticle
      actor.bomb_charge += time_secs
      actor.bomb_charge = min(actor.max_bomb_charge, actor.bomb_charge)
      actor.was_charging_bomb = true
    end

  end

end


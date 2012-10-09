define_actor :foxy do

  has_behaviors do
    positioned
    audible
    layered ZOrder::Player
    # animated_with_spritemap file: 'foxy.png', rows: 9, cols: 3, actions: {
    #   idle:         2,
    #   walking_right:21..23,
    #   walking_left: 21..23,
    #   jumping:      6..7,
    #   falling:      8,
    #   hurt:         9..11,
    #   knocked_down: 24..26,
    # }
    animated_with_spritemap file: 'foxy.png', rows: 9, cols: 3, actions: {
      idle:         1,
      walking_right:1,
      walking_left: 1,
      jumping:      1,
      falling:      1,
      hurt:         1,
      knocked_down: 1,
    }
    grounded

    accelerator air_speed: 16, speed: 30, max_speed: 18 

    shooter recharge_time: 1000, shot_power: 13, kickback: 1.5
    bomber kickback: 5
    die_by_bomb
    shielded

    jump power: 150, rotational_power: 35
    friction amount: 0.05

    foxy_collision_points

    bound_by_box

    tile_oriented
    tile_collision_detector
  end

  view do
    draw do |target, x_off, y_off, z|
      img = actor.image
      return if img.nil?

      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      x_scale = 1
      
      if actor.flip_h
        x_scale = -1
      end

      if actor.can_shoot?
        # TODO move these calcs to the shooter behavior
        gun = actor.gun_direction.dup
        gun.magnitude = 18
        gun = gun.rotate(degrees_to_radians(actor.rotation)) + vec2(offset_x, offset_y)
        target.fill gun.x, gun.y, gun.x+2, gun.y+2, Color::WHITE, ZOrder::PlayerDecoration
      end

      if actor.shields_up?
        shield_image = resource_manager.load_image 'shield.png'
        target.draw_image shield_image, offset_x-shield_image.width/2, 4+offset_y-shield_image.height/2, ZOrder::PlayerDecoration
      end

      rot = normalize_angle(actor.rotation)
      y_scale = 1 - 0.2 * ((actor.jump_power - actor.min_jump_power).to_f / (actor.max_jump_power - actor.min_jump_power))
      y_center_point = y_scale * 0.5
      target.draw_rotated_image img, offset_x, offset_y, z, rot, 0.5, y_center_point, x_scale, y_scale
      # target.draw_box offset_x-img.width/2.0, offset_y-img.height/2.0, offset_x+img.width/2.0, offset_y+img.height/2.0, Color::GREEN, ZOrder::Debug
      
      if ENV['DEBUG']
        bb = actor.bb
        target.draw_box x_off+bb.x, y_off+bb.y, x_off+bb.r, y_off+bb.b, Color::GREEN, ZOrder::Debug

        if $big_bag
          bb = $big_bag
          target.draw_box x_off+bb.x, y_off+bb.y, x_off+bb.r, y_off+bb.b, Color::YELLOW, ZOrder::Debug
        end


        actor.collision_points.each do |cp|
          target.draw_box x_off+cp.x, y_off+cp.y, x_off+cp.x+1, y_off+cp.y+1, Color::WHITE, ZOrder::Debug
        end

        lines = actor.do_or_do_not(:lines) || []
        lines.each do |l|
          one = l[0]
          two = l[1]
          target.draw_line x_off+one[0], y_off+one[1], 
            x_off+two[0], y_off+two[1],
            Color::RED, ZOrder::Debug
        end
      end
    end

  end
end

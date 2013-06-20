define_actor :player do

  has_behaviors do
    positioned
    audible
    layered ZOrder::Player

    # TODO change the interval for one animation
    animated_with_spritemap interval: 120, rows: 7, cols: 8, actions: {
      idle:          [8]*20 + [9],
      walking_right: 32..37,
      walking_left:  32..37,
      jumping:       16,
      asphyxiate:    0..5, 
      slice:         [48]*2+ [49]*3 + [50]*5, 
      shoot_right:   40..41, # TODO do we need left and right?
      shoot_left:    40..41, 
      shoot_down:    42..43, 
      shoot_up:      44..45, 
    }
    grounded
    looker

    accelerator speed: 20
    gibify

    slicer
    shooter recharge_time: 4_000, shot_power: 15, kickback: 1.4
    shielded
    bomber kickback: 1.6

    die_by_sword
    die_by_bullet
    die_by_bomb
    blasted_by_bomb
    disoriented_by_bombs
    die_by_bullet
    shielded

    pulled_by_black_hole
    # die_by_black_hole

    jump max_power: 80, min_power: 20
    friction amount: 0.15

    player_collision_points

    bound_by_box

    tile_oriented
    tile_collision_detector
    asphyxiate
  end

  view do
    draw do |target, x_off, y_off, z|
      img = actor.image
      return if img.nil?

      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      x_scale = -1
      
      if actor.do_or_do_not :flip_h
        x_scale = -x_scale
      end

      if actor.can_shoot?
        gun = actor.gun_tip + vec2(x_off, y_off)
        target.fill gun.x, gun.y, gun.x+2, gun.y+2, Color::WHITE, ZOrder::PlayerDecoration
      end

      if actor.shields_up?
        shield_image = resource_manager.load_image 'trippers/shield.png'
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

        shot_vel = actor.do_or_do_not :shot_vel
        if shot_vel
          target.draw_line offset_x, offset_y, offset_x + shot_vel.x, offset_y + shot_vel.y, 
            Color::WHITE, ZOrder::PlayerDecoration
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

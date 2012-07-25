define_actor :foxy do

  has_behaviors do
    positioned
    audible
    layered ZOrder::Player
    animated_with_spritemap file: 'foxy.png', rows: 9, cols: 3, actions: {
      idle:         2,
      walking_right:21..23,
      walking_left: 21..23,
      jumping:      6..7,
      falling:      8,
      hurt:         9..11,
      knocked_down: 24..26,
    }
    input_mapper(
      [GpLeft, KbLeft] => :move_left,
      [GpRight, KbRight] => :move_right,
      [GpUp, KbUp] => :charging_jump
    )
    grounded
    gravity dir: vec2(0,20)

    accelerator air_speed: 30, speed: 40, max_speed: 18 
    jump anti_gravity_multiplier: 40
    friction amount: 0.04

    foxy_collision_points

    bound_by_box

    tile_bound
    tile_collision_detector

    gravity_manipulator
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
      
      target.draw_rotated_image img, offset_x, offset_y, z, actor.rot, 0.5, 0.5, x_scale
    end

  end
end

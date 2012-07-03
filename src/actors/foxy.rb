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
      KbLeft => :move_left,
      KbRight => :move_right,
      KbUp => :attempt_jump
    )
    grounded
    gravity dir: vec2(0,30)

    accelerator speed: 11, max_speed: 8
    jump
    friction amount: 0.01

    foxy_collision_points

    bound_by_box

    tile_bound
    tile_collision_detector
  end

end


define_actor_view :foxy_view do

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
      offset_x += actor.width
    end
    
    img.draw offset_x, offset_y, z, x_scale, 1
  end

end

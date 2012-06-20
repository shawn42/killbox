define_actor :foxy do
  has_attributes view: :graphical_actor_view

  has_behaviors do
    positioned
    layered ZOrder::Player
    animated_with_spritemap file: 'foxy.png', rows: 9, cols: 3, actions: {
      idle:         2,
      walking_right:21..23,
      walking_left: 21..23,
      jumping:      3..7,
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
    friction amount: 0.01

    accelerator speed: 11, max_speed: 8

    foxy_collision_points

    bound_by_box

    tile_bound
    tile_collision_detector

  end

end


define_actor :foxy do
  has_attributes view: :graphical_actor_view

  has_behaviors do
    positioned
    layered ZOrder::Player
    animated
    input_mapper(
      KbLeft => :move_left,
      KbRight => :move_right,
      KbUp => :attempt_jump
    )
    friction amount: 0.01
    accelerator speed: 11, max_speed: 8

    # not sure where this goes
    foxy_collision_points

    bound_by_box

    tile_bound
    tile_collision_detector

    gravity dir: vec2(0,4)

  end

end


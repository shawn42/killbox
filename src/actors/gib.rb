define_actor :gib do
  
  has_behaviors do
    positioned
    layered ZOrder::Effects
    bound_by_box
    tile_bouncer
    mover
    tile_collision_detector
    trivial_collision_point
  end

  behavior do
    setup do
      add_behavior :short_lived, ttl: (500..4_000).sample
    end
  end

  has_attributes color: Color::RED

  view do
    draw do |target, x_off, y_off, z|
      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      rot = normalize_angle(actor.rotation)

      # use box for now.. add images later
      target.fill offset_x, offset_y, offset_x + actor.size, offset_y + actor.size, actor.color, z
      
    end
  end
end

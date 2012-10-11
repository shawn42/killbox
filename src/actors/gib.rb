define_actor :gib do
  
  has_behaviors do
    positioned
    layered ZOrder::Gib
    bound_by_box
    tile_bouncer
    tile_collision_detector
    trivial_collision_point
  end

  behavior do

    setup do
    end

    helpers do
    end
  end

  view do
    draw do |target, x_off, y_off, z|
      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      rot = normalize_angle(actor.rotation)

      # use box for now.. add images later
      target.fill offset_x, offset_y, offset_x + actor.size, offset_y + actor.size, Color::RED, z
      
    end
  end
end

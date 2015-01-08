define_actor :gib do
  
  has_behaviors do
    positioned
    layered ZOrder::Effects
    bound_by_box
    tile_bouncer
    mover
    tile_collision_detector
    trivial_collision_point
    pulled_by_black_hole
  end

  behavior do
    setup do
      actor.has_attributes bounce_count: 0, max_bounce_count: rand(1..3)
      add_behavior :short_lived, ttl: (4_000..10_000).sample
      reacts_with :bounced
    end

    helpers do
      def bounced
        actor.bounce_count += 1

        # TODO make this randomized slightly
        if actor.bounce_count > actor.max_bounce_count
          remove_behavior :tile_bouncer 
          # full stop
          actor.update_attributes vel: vec2(0,0)
        end

      end
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

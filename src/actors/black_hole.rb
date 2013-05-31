define_actor :black_hole do
  has_behaviors do
    layered ZOrder::BackgroundEffects
    animated_with_spritemap file: 'trippers/black_hole.png', rows: 1, cols: 3, actions: { idle: 0..1 }
    emits_gravity
  end

  # rotation needs to go somewhere better than tile_bouncer
  behavior do
    requires :director

    setup do
      actor.has_attributes rotation: 0, rotation_vel: 1.3
      director.when :update do |time_delta_ms|
        actor.rotation += actor.rotation_vel
      end
    end
  end

  # TODO clean this up? shared view code .. 
  view do
    draw do |target, x_off, y_off, z|
      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      rot = normalize_angle(actor.do_or_do_not(:rotation) || 0)

      img = actor.image
      #target.fill offset_x, offset_y, offset_x+2, offset_y+2, Color::YELLOW, z
      target.draw_rotated_image img, offset_x, offset_y, z, rot#, 0.5, 0.5, x_scale

      if ENV['DEBUG']
        target.draw_circle offset_x, offset_y, actor.gravity_range, Color::WHITE, ZOrder::PlayerDecoration
      end
      
    end
  end
end

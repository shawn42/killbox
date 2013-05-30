define_actor :black_hole do
  has_behaviors do
    layered ZOrder::BackgroundEffects
    animated_with_spritemap file: 'trippers/black_hole.png', rows: 1, cols: 1, actions: { idle: 0 }
    emits_gravity
  end

  # TODO clean this up?
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

      if ENV['DEBUG'] || true
        target.draw_circle offset_x, offset_y, actor.gravity_range, Color::WHITE, ZOrder::PlayerDecoration
      end
      
    end
  end
end

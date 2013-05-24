define_actor :bullet do

  has_behaviors do
    positioned
    audible
    bullet
    layered ZOrder::Player
    animated_with_spritemap file: 'trippers/props.png', rows: 4, cols: 6, actions: { idle: 6..7 }
    bound_by_box
    tile_bound
    tile_collision_detector
    trivial_collision_point
  end

  view do
    draw do |target, x_off, y_off, z|
      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      rot = normalize_angle(actor.rotation)

      img = actor.image
      if img.nil?
        target.fill offset_x, offset_y, offset_x+2, offset_y+2, Color::WHITE, ZOrder::PlayerDecoration
      else
        target.draw_rotated_image img, offset_x, offset_y, z, rot#, 0.5, 0.5, x_scale
      end
    end
  end
end

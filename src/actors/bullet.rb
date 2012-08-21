define_actor :bullet do

  has_behaviors do
    positioned
    audible
    bullet
    layered ZOrder::Player
    animated_with_spritemap file: 'bullet.png', rows: 1, cols: 3, actions: {idle: 0..1}
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
      target.fill offset_x, offset_y, offset_x+2, offset_y+2, Color::WHITE, ZOrder::PlayerDecoration
    end
  end
end

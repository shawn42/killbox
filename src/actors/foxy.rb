define_actor :foxy do
  has_attributes view: :graphical_actor_view
  has_behaviors do
    positioned
    layered ZOrder::Player
    animated
    input_stater(
      KbLeft => :move_left,
      KbRight => :move_right,
      KbUp => :attempt_jump
    )
    mover speed: 0.14

    tile_bound
    tile_collision_detector #(emits :tile_collided, data)
  end

end

class MapInspector

  def solid?(map, x,y)
    tile_grid = map.tile_grid
    tile_size = map.tile_size

    row = y / tile_size
    return false if row > tile_grid.size
    col = x / tile_size
    return false if col > tile_grid[row].size

    tile_grid[row][col]
  end

end

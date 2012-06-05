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
    mover speed: 0.14

    tile_bound
    tile_collision_detector #(emits :tile_collided, data)
  end

end

class MapInspector

  def overlap_tiles(map, box)
    tile_grid = map.tile_grid
    tile_size = map.tile_size

    start_x = box.x / tile_sie.to_i
    start_y = box.y / tile_sie.to_i
    end_x = (box.x + box.width) / tile_sie.to_i
    end_y = (box.y + box.height) / tile_sie.to_i

    (start_x..end_x).each do |row|
      (start_y..end_y).each do |col|
        tile = tile_grid[row][col]
        yield tile, row, col
      end
    end

  end

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

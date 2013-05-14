class MapInspector

  def overlap_tiles(map, box)
    tile_grid = map.tile_grid
    tile_size = map.tile_size

    start_x = box.x.to_i / tile_size.to_i
    start_y = box.y.to_i / tile_size.to_i
    end_x = (box.x + box.width).ceil / tile_size.to_i
    end_y = (box.y + box.height).ceil / tile_size.to_i

    (start_x..end_x).each do |col|
      (start_y..end_y).each do |row|
        col_tiles = tile_grid[row]
        if col_tiles
          tile = col_tiles[col]
          yield tile, row, col
        end
      end
    end

  end

  EPSILON = 0.001
  def calculate_direction(box, hit)
    if Math.abs(hit.x - box.x) < EPSILON
      :left
    elsif Math.abs(hit.x - box.x + box.width) < EPSILON
      :right
    elsif Math.abs(hit.y - box.y) < EPSILON
      :bottom
    else #if Math.abs(hit.y - box.y + box.height) < EPSILON
      :top
    end
  end

  # TODO this will come from the map import eventually
  def solid?(map, row, col)
    return false if row < 0 || col < 0

    trow = map.tile_grid[row]
    return false if trow.nil?
    tile = trow[col]
    return false if tile.nil?

    true
  end

  def line_tile_collision(map, line, row, col)
    tile_size = map.tile_size
    tile_x = col * tile_size
    tile_y = row * tile_size
    tile_box = Rect.new tile_x, tile_y, tile_size, tile_size

    clipped_line = line_tile_collision?(map, line, row, col)
    if clipped_line
      direction = :inside
      if clipped_line.is_a? Array
        direction = 
          if clipped_line[1] == tile_box.y
            :top
          elsif clipped_line[1] == tile_box.bottom
            :bottom
          elsif clipped_line[0] == tile_box.x
            :left
          elsif clipped_line[0] == tile_box.right
            :right
          end
      end

      yield row: row, col: col, tile_face: direction, hit: clipped_line, tile_bb: tile_box
    end

  end

  def line_tile_collision?(map, line, row, col)
    return unless solid?(map, row, col)

    tile_size = map.tile_size
    tile_x = col * tile_size
    tile_y = row * tile_size
    tile_box = Rect.new tile_x, tile_y, tile_size, tile_size

    line_start = line[0]
    line_end = line[1]
    LineClipper.clip line_start[0], line_start[1], line_end[0], line_end[1], tile_box
  end

  def line_of_sight?(actor_a, actor_b)
    map = actor_a.map.map_data
    bb_to_check = actor_a.bb.union(actor_b.bb)
    line = [actor_a.position.to_a, actor_b.position.to_a]
    overlap_tiles(map, bb_to_check) do |tile, row, col|
      return false if line_tile_collision?(map, line, row, col)
    end
    true
  end

  def world_point_solid?(map, x, y)
    tile_size = map.tile_size

    row = y / tile_size
    col = x / tile_size

    solid? map, row, col
  end

  def out_of_bounds?(map, pos)
    tile_grid = map.tile_grid
    tile_size = map.tile_size
    width = tile_grid.first.size * tile_size
    height = tile_grid.size * tile_size
    boundary_size = tile_size * 10

    # TODO cache this on map?
    bb = Rect.new -boundary_size, -boundary_size, width + 2 * boundary_size, 2 * height + boundary_size
    return !bb.collide_point?(pos.x, pos.y)
  end
  
end

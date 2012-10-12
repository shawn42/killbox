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

    return unless solid?(map, row, col)

    tile_size = map.tile_size
    tile_x = col * tile_size
    tile_y = row * tile_size
    tile_box = Rect.new tile_x, tile_y, tile_size, tile_size

    line_start = line[0]
    line_end = line[1]
    clipped_line = LineClipper.clip line_start[0], line_start[1], line_end[0], line_end[1], tile_box

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

      yield row: row, col: col, tile_face: direction, hit: clipped_line
    end

  end

  def world_point_solid?(map, x, y)
    tile_size = map.tile_size

    row = y / tile_size
    col = x / tile_size

    solid? map, row, col
  end

end

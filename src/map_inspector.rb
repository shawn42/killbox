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
        col_tiles = tile_grid[col]
        if col_tiles
          tile = col_tiles[row]
          yield tile, row, col
        end
      end
    end

  end

  def intersection_of(dst1, dst2, p1, p2 )
    return p1 + (p2-p1) * ( -dst1/(dst2-dst1) ) unless ((dst1 * dst2) >= 0) || dst1 == dst2
  end

  def in_box?(hit, b1, b2, axis)
    (axis==:x_axis && hit.y > b1.y && hit.y < b2.y) || (axis==:y_axis && hit.x > b1.x && hit.x < b2.x)
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

  def line_tile_collision(map, line, row, col)

    trow = map.tile_grid[row]
    return unless trow && trow[col]

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

  def _line_tile_collision(map, line, row, col)

    trow = map.tile_grid[row]
    return false unless trow && trow[col]

    tile_size = map.tile_size
    b1 = vec2(col * tile_size, row * tile_size)
    b2 = vec2(b1.x + tile_size, b1.y + tile_size)

    # TODO make this pass in vec2 array for the line? to prevent array object GC
    # TODO make the algo use a Rect
    l1 = vec2(line[0][0],line[0][1])
    l2 = vec2(line[1][0],line[1][1])
    
    # returns true if line (l1, l2) intersects with the box (b1, b2)
    # returns intersection point
    return false if (l2.x < b1.x && l1.x < b1.x)
    return false if (l2.x > b2.x && l1.x > b2.x)
    return false if (l2.y < b1.y && l1.y < b1.y)
    return false if (l2.y > b2.y && l1.y > b2.y)
      # inside?
    yield row: row, col: col, tile_face: :inside if (l1.x > b1.x && l1.x < b2.x && l1.y > b1.y && l1.y < b2.y)

    hit = intersection_of( l1.x-b1.x, l2.x-b1.x, l1, l2) 
    return false unless hit && in_box?( hit, b1, b2, :x_axis )
    hit = intersection_of( l1.y-b1.y, l2.y-b1.y, l1, l2 )
    return false unless hit && in_box?( hit, b1, b2, :x_axis )
    hit = intersection_of( l1.x-b2.x, l2.x-b2.x, l1, l2 )
    return false unless hit && in_box?( hit, b1, b2, :x_axis )
    hit = intersection_of( l1.y-b2.y, l2.y-b2.y, l1, l2 )
    return false unless hit && in_box?( hit, b1, b2, :x_axis )

    direction = calculate_direction(box, hit)
    yield row: row, col: col, tile_face: direction
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

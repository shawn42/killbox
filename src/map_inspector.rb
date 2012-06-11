class MapInspector

  def overlap_tiles(map, box)
    tile_grid = map.tile_grid
    tile_size = map.tile_size

    start_x = box.x.to_i / tile_size.to_i
    start_y = box.y.to_i / tile_size.to_i
    end_x = (box.x + box.width).to_i / tile_size.to_i
    end_y = (box.y + box.height).to_i / tile_size.to_i

    (start_x..end_x).each do |row|
      (start_y..end_y).each do |col|
        row_tiles = tile_grid[row]
        if row_tiles
          tile = row_tiles[col]
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
    tile_size = map.tile_size
    b1 = vec2(row * tile_size, col * tile_size)
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
    return {row: row, col: col, tile_face: :inside} if (l1.x > b1.x && l1.x < b2.x && l1.y > b1.y && l1.y < b2.y)

    hit = intersection_of( l1.x-b1.x, l2.x-b1.x, l1, l2) 
    return false unless hit && in_box?( hit, b1, b2, :x_axis )
    hit = intersection_of( l1.y-b1.y, l2.y-b1.y, l1, l2 )
    return false unless hit && in_box?( hit, b1, b2, :x_axis )
    hit = intersection_of( l1.x-b2.x, l2.x-b2.x, l1, l2 )
    return false unless hit && in_box?( hit, b1, b2, :x_axis )
    hit = intersection_of( l1.y-b2.y, l2.y-b2.y, l1, l2 )
    return false unless hit && in_box?( hit, b1, b2, :x_axis )

    direction = calculate_direction(box, hit)
    {row: row, col: col, tile_face: direction} # for now
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

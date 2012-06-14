INSIDE = 0 # 0000
LEFT = 1   # 0001
RIGHT = 2  # 0010
BOTTOM = 4 # 0100
TOP = 8    # 1000
 
# Compute the bit code for a point (x, y) using the clip rectangle
# bounded diagonally by box
class LineClipper
  def self.calculate_outcode(x, y, box)
    code = INSIDE
    xmin = box.x
    ymin = box.y
    xmax = box.x + box.w
    ymax = box.y + box.h
    if x < xmin
      code |= LEFT
    elsif x > xmax
      code |= RIGHT
    end
    if y < ymin
      code |= BOTTOM
    elsif y > ymax
      code |= TOP
    end
    code
  end

  def self.clip(px0, py0, px1, py1, box)
    cohen_sutherland_line_clip(px0, py0, px1, py1, box)
  end

  # Cohen–Sutherland clipping algorithm clips a line from
  # P0 = (x0, y0) to P1 = (x1, y1) against a rectangle
  def self.cohen_sutherland_line_clip(px0, py0, px1, py1, box)
    x0, y0, x1, y1 = px0, py0, px1, py1
    xmin = box.x
    ymin = box.y
    xmax = box.x + box.w
    ymax = box.y + box.h
    # compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
    outcode0 = calculate_outcode(x0, y0, box)
    outcode1 = calculate_outcode(x1, y1, box)
    accept = false

    loop do

      if (outcode0 | outcode1) == 0
        accept = true
        break
      elsif (outcode0 & outcode1) != 0
        break
      else
        # failed both tests, so calculate the line segment to clip
        # from an outside point to an intersection with clip edge
        x = nil
        y = nil

        # At least one endpoint is outside the clip rectangle pick it.
        outcode_out = outcode0 != 0 ? outcode0 : outcode1

        # Now find the intersection point
        # use formulas y = y0 + slope * (x - x0), x = x0 + (1 / slope) * (y - y0)
        if (outcode_out & TOP) != 0
          x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0)
          y = ymax
        elsif (outcode_out & BOTTOM) != 0
          x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0)
          y = ymin
        elsif (outcode_out & RIGHT) != 0
          y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0)
          x = xmax
        elsif (outcode_out & LEFT) != 0 # maybe make this else?
          y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0)
          x = xmin
        end

        # Now we move outside point to intersection point to clip
        # and get ready for next pass.
        if (outcode_out == outcode0)
          x0 = x
          y0 = y
          outcode0 = calculate_outcode(x0, y0, box)
        else
          x1 = x
          y1 = y
          outcode1 = calculate_outcode(x1, y1, box)
        end
      end
    end

    if accept
      if x0 == px0 && y0 == py0 && x1 == px1 && y1 == py1
        # we didn't clip
        true
      else
        [x0, y0, x1, y1]
      end
    else
      nil
    end
  end
end


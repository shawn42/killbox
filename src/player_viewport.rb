class PlayerViewport < Viewport
  attr_accessor :x_scr_offset, :y_scr_offset

  def initialize(x_scr_offset, y_scr_offset, width, height)
    super(width, height)
    @x_scr_offset = x_scr_offset
    @y_scr_offset = y_scr_offset
    @speed = 0.2
  end

  def self.create_n(players, total_size)
    case players.size
    when 1  
      vp1 = PlayerViewport.new 0, 0, total_size[0], total_size[1]
      vp1.follow players[0]#, [0,0]#, [100,100]

      [vp1]
    when 2  # SPLIT VERTICALLY IN HALF
      half_width = total_size[0]/2

      vp1 = PlayerViewport.new 0, 0, half_width, total_size[1]
      vp1.follow players[0]#, [0,0]#, [100,100]

      vp2 = PlayerViewport.new half_width, 0, half_width, total_size[1]
      vp2.follow players[1], [vp2.width, 0] #, [100,100]
      [vp1, vp2]
    else
      [] #TODO
    end
  end

  def update(time)
    scrolled = false
    if @follow_target
      x = @follow_target.x
      y = @follow_target.y
      if @x_offset_range
        x = @x_offset_range.min if @x_offset_range.min > x 
        x = @x_offset_range.max if @x_offset_range.max < x 
      end
      if @y_offset_range
        y = @y_offset_range.min if @y_offset_range.min > y 
        y = @y_offset_range.max if @y_offset_range.max < y 
      end
      x_diff = @width/2 + @follow_offset_x - x - @x_offset
      if x_diff.abs > @buffer_x
        # move screen 
        if x_diff > 0
          @x_offset += (x_diff - @buffer_x) * @speed
        else
          @x_offset += (x_diff + @buffer_x) * @speed
        end

        scrolled = true
      end

      y_diff = @height/2 + @follow_offset_y - y - @y_offset
      if y_diff.abs > @buffer_y
        # move screen
        if y_diff > 0
          @y_offset += (y_diff - @buffer_y) * @speed
        else
          @y_offset += (y_diff + @buffer_y) * @speed
        end
        scrolled = true
      end

      if @follow_target.respond_to? :rotation
        norm_target_rot = normalize_angle(@follow_target.rotation)
        rot_diff = @rotation - norm_target_rot
        # rot_diff = normalize_angle(norm_target_rot - @rotation) if rot_diff.abs > 180
        if rot_diff.abs < 0.01
          @rotation = norm_target_rot 
        else
          @rotation = normalize_angle(@rotation - rot_diff * @speed)
        end
      end

      # constrain_x_offset
      if @boundary && @width < (@boundary[2] - @boundary[0])
        if @x_offset > 0 - @boundary[0] # Left-wall bump
          @x_offset = @boundary[0]
        elsif @x_offset < @width - @boundary[2] # right-wall bump
          @x_offset = @width - @boundary[2]
        end
      end

      # constrain_y_offset
      if @boundary && @height < (@boundary[3] - @boundary[1])
        if @y_offset > 0 - @boundary[1]
          @y_offset = @boundary[1]
        elsif @y_offset < @height - @boundary[3]
          @y_offset = @height - @boundary[3]
        end
      end

      fire :scrolled if scrolled
    end
  end

  def follow(target, off=[0,0], buff=[0,0])
    @follow_target = target
    @follow_offset_x = off[0]
    @follow_offset_y = off[1]
    @buffer_x = buff[0]
    @buffer_y = buff[1]

    @x_offset = @width/2 - @follow_target.x + @follow_offset_x
    @y_offset = @height/2 - @follow_target.y + @follow_offset_y

    if @target.respond_to? :rotation
      @rotation = @target.rotation
    end

    fire :scrolled
  end

  def world_bounds
    left = -@x_offset
    top = -@y_offset
    Rect.new left, top, @width, @height
  end

  def screen_bounds
    left = @x_scr_offset
    top = @y_scr_offset
    Rect.new left, top, @width, @height
  end

end

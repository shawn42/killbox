class LevelPlayStage < Stage
  include GameSession
  include GameLogic

  def setup
    super
    director.update_slots = [:first, :before, :update, :last]
    $debug_drawer = DebugDraw.new

    # TODO XXX hack until all other stages are in place
    init_session

    reset_timer

    # @hud = spawn :hud, :session => session
    create_actor :fps, x:10, y:10, layer: ZOrder::Debug

    @level = LevelLoader.load self, current_level

    @foxy = @level.named_objects[:foxy]
    @foxy.vel = vec2(0,5)

    viewport.speed = 0.1
    # viewport.boundary = @level.map_extents

    viewport.follow @foxy#, [0,0], [100,100]

    input_manager.reg :down, KbU do
      @foxy.x = 200
      @foxy.y = 100
      @foxy.rotation = (45..138).to_a.sample
      @foxy.on_ground = false
      behs = @foxy.instance_variable_get('@behaviors')
      @foxy.vel = vec2(0,5)
    end
  end

  def draw(target)
    super
    @color ||= Color.new 255, 41, 145, 179
    target.fill_screen @color, -1
    $debug_drawer.draw_blocks.each do |name, dblock|
      dblock.call target
    end
  end
end

class DebugDraw
  attr_reader :draw_blocks
  def initialize
    clear
  end

  def clear
    @draw_blocks = {}
  end

  def draw(name, &block)
    @draw_blocks[name] = block
  end
end

class Viewport

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

end

class LevelPlayStage < Stage
  include GameSession

  attr_accessor :players, :viewports

  def setup
    super

    director.update_slots = [:first, :before, :update, :last]
    $debug_drawer = DebugDraw.new

    # TODO XXX hack until all other stages are in place
    init_session

    @level = LevelLoader.load self

    @foxy = @level.named_objects[:player1]
    @foxy.vel = vec2(0,5)
    # should behaviors just be constructed with an actor's input?
    @foxy.input.map_input(
      '+b' => :shoot,
      '+n' => :charging_jump,
      '+m' => :charging_bomb, # TODO
      '+w' => :look_up,
      '+a' => [:look_left, :walk_left],
      '+d' => [:look_right, :walk_right],
      '+s' => :look_down,
    )

    @other = @level.named_objects[:player2]
    @other.vel = vec2(0,5)
    # should behaviors just be constructed with an actor's input?
    @other.input.map_input(
      '+i' => :shoot,
      '+o' => :charging_jump,
      '+p' => :charging_bomb, # TODO
      '+t' => :look_up,
      '+f' => [:look_left, :walk_left],
      '+h' => [:look_right, :walk_right],
      '+g' => :look_down,
    )

    @players = [@foxy, @other]
    @viewports = PlayerViewport.create_n @players, config_manager[:screen_resolution]
    # this_object_context[:viewport] = @viewport
    
    input_manager.reg :down, KbU do
      @foxy.x = 200
      @foxy.y = 100
      @foxy.rotation = (45..138).to_a.sample
      @foxy.on_ground = false
      behs = @foxy.instance_variable_get('@behaviors')
      @foxy.vel = vec2(0,5)
    end
  end

  def update(time)
    super
    @viewports.each do |vp|
      vp.update time
    end
  end

  def draw(target)
    @viewports.each do |vp|
      draw_viewport target, vp
    end
  end

  def draw_viewport(target, viewport)
    center_x = viewport.width / 2
    center_y = viewport.height / 2

    target.draw_box(
      viewport.x_scr_offset,
      viewport.y_scr_offset, 
      viewport.x_scr_offset+viewport.width,
      viewport.y_scr_offset+viewport.height, Color::BLACK, ZOrder::HudText)

    target.clip_to(*viewport.screen_bounds) do
      target.rotate(-viewport.rotation, center_x, center_y) do
        z = 0
        @parallax_layers.each do |parallax_layer|
          drawables_on_parallax_layer = @drawables[parallax_layer]

          if drawables_on_parallax_layer
            @layer_orders[parallax_layer].each do |layer|

              trans_x = viewport.x_offset parallax_layer
              trans_y = viewport.y_offset parallax_layer

              z += 1
              drawables_on_parallax_layer[layer].each do |drawable|
                drawable.draw target, trans_x, trans_y, z
              end
            end
          end
        end
      end # rotate
    end # clip_to

    @color ||= Color.new 255, 41, 145, 179
    #target.fill_screen @color, -1
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

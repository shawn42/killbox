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

    viewport.speed = 0.1
    viewport.boundary = @level.map_extents

    viewport.follow @foxy, [0,0], [100,100]
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

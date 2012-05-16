class LevelPlayStage < Stage
  include GameSession
  include GameLogic

  def setup
    super
    # TODO XXX hack until all other stages are in place
    init_session

    reset_timer

    # @hud = spawn :hud, :session => session
    create_actor :fps, x:10, y:10, layer: ZOrder::Debug

    @level = LevelLoader.load self, current_level

    @foxy = @level.named_objects[:foxy]

    viewport.speed = 0.1
    viewport.boundary = @level.map_extents

    # viewport.follow @foxy, [0,0], [100,100]
  end
end


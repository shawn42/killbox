class BlackHoleCoordinator
  def initialize
    @active_black_holes = []
    @active_pullables = []
  end

  def register_black_hole(black_hole)
    @active_black_holes << black_hole
  end

  def unregister_black_hole(black_hole)
    @active_black_holes.delete black_hole
  end

  def register_pullable(pullable)
    pullable.when :position_changed do
      @active_black_holes.each do |black_hole|
        distance = (pullable.position - black_hole.position).magnitude

        if distance < black_hole.gravity
          black_hole.react_to :pull, pullable
        end
      end
    end

    @active_pullables << pullable
  end

  def unregister_pullable(pullable)
    pullable.unsubscribe_all self
    @active_pullables.delete pullable
  end
end

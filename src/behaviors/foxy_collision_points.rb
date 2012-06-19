define_behavior :foxy_collision_points do
  setup do
    # requires_attributes :x, :y, :width, :height

    actor.has_attributes collision_points: points

    actor.when :position_changed do
      actor.collision_points = points
    end
  end

  helpers do
    def points
      x = actor.x
      y = actor.y
      w = actor.width
      h = actor.height
      qh = h * 0.25
      tqh = h * 0.75

      #
      #  0     1
      #   -----
      # 7 |    | 2
      #   |FOXY|
      # 6 |    | 3
      #   -----
      #  5     4

      [
        vec2(x,y),

        vec2(x+w,y),
        vec2(x+w,y+qh),
        vec2(x+w,y+tqh),
        vec2(x+w,y+h),

        vec2(x,y+h),
        vec2(x,y+tqh),
        vec2(x,y+qh),
      ]
    end
  end
end

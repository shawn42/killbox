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
      # TODO save these off
      quarter_w = w * 0.25
      quarter_h = h * 0.25
      three_quarter_h = h - quarter_h
      three_quarter_w = w - quarter_w

      [
        vec2(x+quarter_w,       y),
        vec2(x+three_quarter_w, y),

        vec2(x+w,               y+quarter_h),
        vec2(x+w,               y+three_quarter_h),

        vec2(x+three_quarter_w, y+h-3),
        vec2(x+quarter_w,       y+h-3),

        vec2(x,                 y+three_quarter_h),
        vec2(x,                 y+quarter_h),
      ]
    end
  end
end

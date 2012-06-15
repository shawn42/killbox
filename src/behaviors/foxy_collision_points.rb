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
      offset = 2

      [
        vec2(x+offset, y),
        vec2(x+w-offset, y),

        vec2(x+w,               y+offset),
        vec2(x+w,               y+h-3-offset),

        vec2(x+offset, y+h-3),
        vec2(x+w-offset,       y+h-3),

        vec2(x,                 y+offset),
        vec2(x,                 y+h-3-offset),
      ]
    end
  end
end

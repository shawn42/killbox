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

      [
        vec2(x,y),
        vec2(x+w,y),
        vec2(x+w,y+h),
        vec2(x,y+h),
      ]
    end
  end
end

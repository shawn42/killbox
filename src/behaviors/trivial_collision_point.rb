define_behavior :trivial_collision_point do
  setup do
    actor.has_attributes collision_points: points,
      collision_point_deltas: [vec2(0,0)]

    actor.when :position_changed do
      actor.collision_points = points
    end
  end

  helpers do
    def points
      [vec2(actor.x,actor.y)]
    end
  end
end

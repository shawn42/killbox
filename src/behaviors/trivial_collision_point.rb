define_behavior :trivial_collision_point do
  setup do
    actor.has_attributes collision_points: points

    actor.when :position_changed do
      actor.collision_points = points
    end
  end

  helpers do
    def points
      [vec2(actor.x,actor.y)]
    end

    def rotate(point)
      #fuh
    end
  end
end

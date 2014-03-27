define_behavior :bomb_collision_points do
  setup do
    actor.has_attributes collision_point_deltas: point_deltas,
    collision_points: points

    actor.when :position_changed do
      actor.collision_points = points
    end
    actor.when :rotation_changed do
      actor.collision_points = points
    end
  end

  remove do
    actor.unsubscribe_all self
  end

  helpers do
    def points
      x = actor.x
      y = actor.y

      point_deltas.map do |point|
        rotate(actor.position, point)
      end
    end

    def point_deltas
      w = 18 #22
      h = 6 #9
      hw = w / 2.0
      hh = h / 2.0
      [
        vec2(-hw,-hh),
        vec2(hw,-hh),
        vec2(hw,hh),
        vec2(-hw,hh)
      ]
    end

    def rotate(actor_loc, point)
      rotation = actor.do_or_do_not(:rotation) || 0
      point.rotate(degrees_to_radians(rotation)) + actor_loc
    end
  end
end

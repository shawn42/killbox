define_behavior :foxy_collision_points do
  setup do
    actor.has_attributes collision_point_deltas: point_deltas,
    collision_points: points

    actor.when :position_changed do
      actor.collision_points = points
    end
    actor.when :rotation_changed do
      actor.collision_points = points
    end

    reacts_with :remove
  end

  helpers do
    def points
      #
      #  0     1
      #   -----
      # 7 |    | 2
      #   |FOXY|
      # 6 |    | 3
      #   -----
      #  5     4
      point_deltas.map do |point|
        rotate(actor.position, point)
      end
    end

    def point_deltas
      w = 32#actor.width
      h = 60#actor.height
      hw = w / 2.0
      hh = h / 2.0
      qh = h * 0.25

      [
        vec2(-hw,-hh),

        vec2(hw,-hh),
        vec2(hw,-qh),
        vec2(hw,qh),
        vec2(hw,hh),

        vec2(-hw,hh),
        vec2(-hw,qh),
        vec2(-hw,-qh),
      ]
    end

    def rotate(actor_loc, point)
      rotation = actor.do_or_do_not(:rotation) || 0
      point.rotate(degrees_to_radians(rotation)) + actor_loc
    end

    def remove
      actor.unsubscribe_all self
    end
  end
end

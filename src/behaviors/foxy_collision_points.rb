define_behavior :foxy_collision_points do
  setup do
    actor.has_attributes collision_points: points

    actor.when :position_changed do
      actor.collision_points = points
    end
  end

  helpers do
    def points
      x = actor.x
      y = actor.y
      actor_loc = vec2(x,y)
      w = actor.width
      h = actor.height
      hw = w / 2
      hh = h / 2
      qh = h * 0.25

      #
      #  0     1
      #   -----
      # 7 |    | 2
      #   |FOXY|
      # 6 |    | 3
      #   -----
      #  5     4

      [
        vec2(-hw,-hh),

        vec2(hw,-hh),
        vec2(hw,-qh),
        vec2(hw,qh),
        vec2(hw,hh),

        vec2(-hw,hh),
        vec2(-hw,qh),
        vec2(-hw,-qh),
      ].map do |point|
        rotate(actor_loc, point)
      end
    end

    def rotate(actor_loc, point)
      rotation = actor.do_or_do_not(:rotation) || 0
      point.rotate(degrees_to_radians(rotation)) + actor_loc
    end
  end
end

define_behavior :shielded_collision_points do
  setup do
    actor.has_attributes :collision_point_deltas, 
      :collision_points

    actor.when :position_changed do
      actor.collision_points = points
    end
    actor.when :rotation_changed do
      actor.collision_points = points
    end

    actor.collision_points = points
    actor.collision_point_deltas = point_deltas
  end

  remove do
    actor.unsubscribe_all self
  end

  helpers do
    def points
      point_deltas.map do |point|
        rotate(actor.position, point)
      end
    end

    def point_deltas
      w = 32#actor.width
      h = 60#actor.height
      hw = w / 2.0
      qw = w * 0.25
      hh = h / 2.0
      qh = h * 0.25

      [
        vec2(-hw,-hh),
        vec2(0,-hh-5),
        vec2(hw,-hh),

        vec2(hw+qw,-qh),
        vec2(hw+qw,0),
        vec2(hw+qw,qh),

        vec2(hw,hh-1),
        vec2(0,hh+5-1),
        vec2(-hw,hh-1),

        vec2(-hw-qw,qh),
        vec2(-hw-qw,0),
        vec2(-hw-qw,-qh),
      ]
    end

    def rotate(actor_loc, point)
      rotation = actor.do_or_do_not(:rotation) || 0
      point.rotate(degrees_to_radians(rotation)) + actor_loc
    end
  end
end

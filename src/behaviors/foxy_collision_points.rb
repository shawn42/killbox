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
        vec2(x-hw,y-hh),

        vec2(x+hw,y-hh),
        vec2(x+hw,y-qh),
        vec2(x+hw,y+qh),
        vec2(x+hw,y+hh),

        vec2(x-hw,y+hh),
        vec2(x-hw,y+qh),
        vec2(x-hw,y-qh),
      ].each do |point|
        rotate(point)
      end
    end

    def rotate(point)
      point
      # dx = nucleus.shell_distance * @shell * Math.cos(actor.rot)
      # dy = @nucleus.shell_distance * @shell * Math.sin(actor.rot)
      # self.x = dx+@nucleus.x
      # self.y = dy+@nucleus.y
    end
  end
end

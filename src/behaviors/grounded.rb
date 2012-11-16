# needed to prevent us from mid-air jumping if you've run off a cliff
define_behavior :grounded do
  requires :director, :map_inspector
  setup do
    actor.has_attributes on_ground: false

    director.when :first do
      feet_points = [actor.collision_points[4], actor.collision_points[5]]

      actor_loc = vec2(actor.x, actor.y)
      touching_points = actor.collision_points.select { |fp| on_ground?(fp) }
      # TODO actor.react_to :left_ground # should rotate now
      actor.on_ground = touching_points.size > 0
      # actor.action = :idle unless actor.action == :idle
    end

  end
  
  helpers do
    def on_ground?(fp)
      down_vector = vec2(0,4).rotate(degrees_to_radians(actor.rotation))
      down_fp = down_vector + fp
      map_inspector.world_point_solid?(actor.map.map_data, down_fp.x, down_fp.y)
    end
  end
end

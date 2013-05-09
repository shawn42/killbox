# needed to prevent us from mid-air jumping if you've run off a cliff
define_behavior :grounded do
  requires :director, :map_inspector
  setup do
    actor.has_attributes on_ground: false

    director.when :first do
      feet_points = actor.collision_points[4..5]
      actor.on_ground = feet_points.any? { |fp| on_ground?(fp) }
    end

    actor.when :on_ground_changed do |was_grounded, is_grounded|
      unless is_grounded
        # TODO DO NOT USE GUN DIRECTION!!
        gun_angle = actor.gun_direction.angle
        if gun_angle == 0
          actor.rotation_vel = -0.3 
        elsif gun_angle == Math::PI
          actor.rotation_vel = 0.3 
        end
      end
    end

    react_to :remove
  end
  
  helpers do
    def remove
      director.unsubscribe_all self
    end

    def on_ground?(fp)
      down_vector = vec2(0,4).rotate(degrees_to_radians(actor.rotation))
      down_fp = down_vector + fp
      map_inspector.world_point_solid?(actor.map.map_data, down_fp.x, down_fp.y)
    end
  end
end

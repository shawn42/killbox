define_behavior :tile_bouncer do
  requires :map_inspector, :stage
  setup do
    raise "vel required" unless actor.has_attribute? :vel

    actor.has_attribute :rotation_vel, 0

    actor.when :tile_collisions do |collisions|
      map = actor.map.map_data

      # TODO move these to some sort of CollisionInspector
      interesting_collisions = collisions.select do |collision|
        face_normal = FACE_NORMALS[collision[:tile_face]]
        # no tile next to
        face_normal && !map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)
      end

      closest_collision = interesting_collisions.min_by do |collision|
        hit = collision[:hit]
        hit_vector = vec2(hit[0], hit[1])
        (hit_vector - actor.position).magnitude
      end

      if closest_collision
        hit = closest_collision[:hit]
        hit_vector = vec2(hit[0], hit[1])
        penetration = vec2(hit[2], hit[3])

        left_over = (penetration - hit_vector).magnitude

        cps = actor.collision_points
        face_normal = FACE_NORMALS[closest_collision[:tile_face]]

        point_that_collided = cps[closest_collision[:point_index]]

        motion = penetration - point_that_collided 
        reversed_vel = motion.reverse
        projected = motion.projected_onto(face_normal)

        new_vel = (projected - motion).reverse + projected.reverse

        old_vel = actor.vel
        actor.vel = new_vel

        left_over_movement = new_vel.dup
        left_over_movement.magnitude = left_over
        new_loc = hit_vector + left_over_movement + (actor.position - point_that_collided)

        if cps.size > 1
          old_unit = old_vel.unit.reverse
          new_unit = new_vel.unit
          dot = old_unit.dot(new_unit)
          perp_dot = old_unit.x * new_unit.y - old_unit.y * new_unit.x
          signed_angle = Math.atan2(perp_dot, dot)

          actor.rotation_vel = signed_angle*0.3
        end

        actor.update_attributes x: new_loc.x, y: new_loc.y

      else
        # raise "collided, but no good collisions in [#{collisions}]"
        actor.emit :no_tile_collisions
      end
    end
  end

  remove do
    actor.unsubscribe_all self
  end

  helpers do
    include MinMaxHelpers
  end
end

define_behavior :tile_bouncer do
  requires :map_inspector
  setup do
    raise "vel required" unless actor.has_attribute? :vel

    actor.when :tile_collisions do |collisions|
      if collisions

        map = actor.map.map_data
        actor_loc = vec2(actor.x, actor.y)

        log collisions
        interesting_collisions = collisions.select do |collision|
          face_normal = FACE_NORMALS[collision[:tile_face]]
          # no tile next to
          face_normal && !map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)
        end

        closest_collision = interesting_collisions.min_by do |collision|
          hit = collision[:hit]
          hit_vector = vec2(hit[0], hit[1])
          actor_loc = vec2(actor.x, actor.y)
          (hit_vector - actor_loc).magnitude
        end
        if closest_collision

          hit = closest_collision[:hit]
          hit_vector = vec2(hit[0], hit[1])
          penetration = vec2(hit[2], hit[3])

          left_over = (penetration - hit_vector).magnitude

          face_normal = FACE_NORMALS[closest_collision[:tile_face]]
          reversed_vel = actor.vel.reverse
          
          projected = actor.vel.projected_onto(face_normal)

          new_vel = (projected - actor.vel).reverse + projected.reverse
          actor.vel = new_vel

          cps = actor.collision_points

          left_over_movement = new_vel.dup
          left_over_movement.magnitude = left_over
          new_loc = hit_vector + left_over_movement + (actor_loc - cps[closest_collision[:point_index]])

          actor.x = new_loc.x
          actor.y = new_loc.y
        else
          # binding.pry
        end

      else

        actor.x += actor.vel.x 
        actor.y += actor.vel.y
      end
    end
  end

  helpers do
    # TODO how to DRY this up w/ other behaviors? just define in some constants.rb?
    FACE_NORMALS = {
      top:    vec2(0, -1),
      bottom: vec2(0, 1),
      left:   vec2(-1, 0),
      right:  vec2(1, 0),
    } unless defined? FACE_NORMALS
  end
end

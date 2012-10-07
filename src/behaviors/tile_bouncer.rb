define_behavior :tile_bouncer do
  requires :map_inspector
  setup do
    raise "vel required" unless actor.has_attribute? :vel

    actor.has_attribute :rotation_vel, 0

    actor.when :tile_collisions do |collisions|
      if collisions
        map = actor.map.map_data
        actor_loc = vec2(actor.x, actor.y)


        # TODO move these to some sort of CollisionInspector
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
          # log "ACTOR #{actor}"
          log "CLOSEST"
          log closest_collision

          hit = closest_collision[:hit]
          hit_vector = vec2(hit[0], hit[1])
          penetration = vec2(hit[2], hit[3])

          left_over = (penetration - hit_vector).magnitude

          cps = actor.collision_points
          face_normal = FACE_NORMALS[closest_collision[:tile_face]]

          point_that_collided = cps[closest_collision[:point_index]]
          motion = penetration - point_that_collided 
          # motion = actor.vel

          reversed_vel = motion.reverse
          
          projected = motion.projected_onto(face_normal)

          new_vel = (projected - motion).reverse + projected.reverse

          # XXX bandaide ... no longer stuck.. but 
          actor.rotation_vel *= -1

          actor.vel = new_vel

          left_over_movement = new_vel.dup
          left_over_movement.magnitude = left_over
          new_loc = hit_vector + left_over_movement + (actor_loc - point_that_collided)

          actor.rotation += actor.rotation_vel
          actor.x = new_loc.x
          actor.y = new_loc.y
          log "UPDATED ACTOR #{actor.x} #{actor.y} #{actor.rotation} #{actor.vel}"
        else
          raise "collided, but no good collisions in [#{collisions}]"
        end

      else
        actor.rotation += actor.rotation_vel
        actor.x += actor.vel.x 
        actor.y += actor.vel.y
      end
    end

    reacts_with :remove
  end

  helpers do
    # TODO how to DRY this up w/ other behaviors? just define in some constants.rb?
    FACE_NORMALS = {
      top:    vec2(0, -1),
      bottom: vec2(0, 1),
      left:   vec2(-1, 0),
      right:  vec2(1, 0),
    } unless defined? FACE_NORMALS

    def remove
      actor.unsubscribe_all self
    end
  end
end

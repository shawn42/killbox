define_behavior :tile_oriented do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    actor.has_attribute :ground_normal, vec2(0, -1)

    actor.when :tile_collisions do |collisions|
      if collisions
        map = actor.map.map_data

        first_collision = nil

        interesting_collisions = collisions.select do |collision|
          face_normal = FACE_NORMALS[collision[:tile_face]]
          # no tile next to
          face_normal && !map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)
        end

        # get collision that would occur first
        closest_collision = interesting_collisions.min_by do |collision|
          hit = collision[:hit]
          hit_vector = vec2(hit[0], hit[1])
          actor_loc = vec2(actor.x, actor.y)
          (hit_vector = actor_loc).magnitude
        end


        if closest_collision
          face_normal = FACE_NORMALS[closest_collision[:tile_face]]
          raise "Y NO COL FACE?" if closest_collision[:tile_face].nil?
          raise "Y NO FACE?" if face_normal.nil?
          actor.ground_normal = face_normal 

          set_actor_rotation closest_collision[:tile_face]
          set_actor_location closest_collision
          actor.emit :hit_bottom
        else
          apply_actor_velocities
          # log "actor rotating from #{actor.rotation} += #{radians_to_degrees(actor_rotation_delta)}"
          # actor.rotation = normalize_angle(actor.rotation + radians_to_degrees(actor_rotation_delta))
        end
      else
        apply_actor_velocities
      end

      # log "APPLYING ROT VEL: #{actor.rotation_vel} making #{actor.rotation}" unless actor.rotation_vel == 0
      # DEBUG!
      # vb = Rect.new(viewport.boundary)
      # actor.y = 10 if actor.y > vb.bottom
      # actor.y = 600 if actor.y < vb.y
      # actor.x = 0 if actor.x > vb.right
      # actor.x = vb.right-100 if actor.x < vb.x
    end
  end

  helpers do
    FACE_NORMALS = {
      top:    vec2(0, -1),
      bottom: vec2(0, 1),
      left:   vec2(-1, 0),
      right:  vec2(1, 0),
    } unless defined? FACE_NORMALS
    ROTATIONS = {
      top:    0,
      bottom: 180,
      left:   90,
      right:  270
    } unless defined? ROTATIONS

    def apply_actor_velocities
      actor.x += actor.vel.x 
      actor.y += actor.vel.y
      actor.rotation = actor.rotation + actor.rotation_vel
    end

    def set_actor_rotation(tile_face)
      actor.rotation_vel = 0
      actor.rotation = ROTATIONS[tile_face]
    end

    def set_actor_location(collision)
      tile_row = collision[:row] 
      tile_col = collision[:col] 

      # TODO move to map inspector?
      map = actor.map.map_data
      cps = actor.collision_points
      tile_size = map.tile_size
      actor_loc = vec2(actor.x, actor.y)

      log "="*80
      log collision
      log actor_loc

      case collision[:tile_face]
      when :top
        lower_left_target = vec2(tile_col * tile_size, tile_row * tile_size - 1)
      when :bottom
        lower_left_target = vec2((tile_col + 1) * tile_size, (tile_row + 1) * tile_size)
      when :left
        lower_left_target = vec2(tile_col * tile_size, (tile_row + 1) * tile_size)
      when :right
        lower_left_target = vec2((tile_col + 1) * tile_size, tile_row * tile_size)
      else
        raise "cannot determin desired actor location from tile_face: #{collision[:tile_face]}"
      end
      $thing = lower_left_target


      new_loc = lower_left_target + (actor_loc - cps[5])
      actor.x = new_loc.x
      actor.y = new_loc.y
      # actor.y = lower_left_target.y - 20

      log vec2(actor.x, actor.y)
    end


  end
end

define_behavior :tile_oriented do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    actor.has_attribute :ground_normal, vec2(0, -1)

    actor.when :tile_collisions do |collisions|
      if collisions
        map = actor.map.map_data

        collisions.each do |collision|

          face_normal = FACE_ROTATIONS[collision[:tile_face]]

          next if face_normal && map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)

          unless collision[:tile_face] == :inside || face_normal.nil?
            actor.ground_normal = face_normal 
          end

          unless actor.on_ground || actor.jump_power > actor.min_jump_power || face_normal.nil? || map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)

            puts "apply collision #{collision[:tile_face]}"
            actor.accel.x = 0
            actor.accel.y = 0
            actor.vel.x = 0
            actor.vel.y = 0
            actor.rotation_vel = 0

            hit = collision[:hit]
            hit_vector = vec2(hit[0], hit[1])
            # $count ||= 0
            # $count += 1
            # bb = actor.bb.dup
            # $debug_drawer.draw("foxy_bb#{$count}") do |t|
            #   t.fill bb.x, bb.y, bb.r, bb.b, [255,0,0,150], ZOrder::Debug
            # end

            # $debug_drawer.draw("hit_vector#{$count}") do |t|
            #   t.fill hit_vector.x, hit_vector.y, hit_vector.x+2, hit_vector.y+2, [255,255,250], ZOrder::Debug
            # end
            # x = actor.x
            # y = actor.y
            # $debug_drawer.draw("foxy_position#{$count}") do |t|
            #   t.fill x, y, x+2, y+2, [0,0,255], ZOrder::Debug
            # end

            actor_loc = vec2(actor.x, actor.y)

            to_floor = vec2(0,(actor.height/2.0)+1)
            rotated_to_floor = to_floor.rotate(degrees_to_radians(actor.rotation))
            rotated_bottom = actor_loc + rotated_to_floor

            actor_translation = hit_vector + face_normal * to_floor.y
            # actor_rotation_delta = face_normal.angle_with(actor_loc - rotated_bottom)
            actor_rotation_delta = face_normal.angle - (actor_loc - rotated_bottom).angle

            actor_translation.x -= rotated_to_floor.x

            # log "="*80
            # log hit_vector
            # log actor_loc
            # log actor.rotation
            # log face_normal
            # log actor_loc - rotated_bottom
            # log actor_translation
            # log actor_rotation_delta
            # log "rotated to_floor x: #{rotated_to_floor.x}"

            # actor.x = actor_translation.x.round
            actor.y = actor_translation.y.round
            log "actor rotating from #{actor.rotation} += #{radians_to_degrees(actor_rotation_delta)}"
            actor.rotation = normalize_angle(actor.rotation + radians_to_degrees(actor_rotation_delta))
            actor.remove_behavior :gravity
            actor.emit :hit_bottom
            break
          end
        end

      end

      actor.x += actor.vel.x 
      actor.y += actor.vel.y
      actor.rotation = actor.rotation + actor.rotation_vel

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
    FACE_ROTATIONS = {
      top:    vec2(0, -1),
      bottom: vec2(0, 1),
      left:   vec2(-1, 0),
      right:  vec2(1, 0),
      inside: vec2(0, 0),
    }
  end
end

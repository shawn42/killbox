define_behavior :tile_bound do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    # $debug_drawer.draw(:foxy_bb) do |target|
    #   target.draw_box(bb,y1,x2,y2,color, z)
    # end
    actor.when :tile_collisions do |collisions|
      if collisions
        map = actor.map.map_data
        new_x = nil
        new_y = nil

        collisions.each do |collision|

          face_normal = FACE_ROTATIONS[collision[:tile_face]]
          unless face_normal.nil? || map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)

            hit = collision[:hit]
            hit_vector = vec2(hit[0], hit[1])

            actor_loc = vec2(actor.x, actor.y)

            thing = vec2(0,actor.height/2.0)
            rotated_thing = thing.rotate(actor.rot)
            rotated_bottom = actor_loc + rotated_thing

            # actor_translation = hit_vector - rotated_bottom
            actor_translation = hit_vector + face_normal * thing.y
            actor_rotation_delta = face_normal.angle_with(actor_loc - rotated_bottom)

            actor_translation.x -= rotated_thing.x

            hx = hit_vector.x
            hy = hit_vector.y
            $debug_drawer.draw(:hit_vector) do |target|
              target.fill(hx,hy,hx+2,hy+2,[255,0,0], ZOrder::Debug)
            end
            ax = actor.x
            ay = actor.y
            $debug_drawer.draw(:foxy_collision) do |target|
              target.fill(ax,ay, ax+4, ay+4, [0,255,0], ZOrder::Debug)
            end

            log "="*80
            log hit_vector
            # log actor_loc
            # log actor.rot
            log face_normal
            log actor_loc - rotated_bottom
            # log actor_translation
            log actor_rotation_delta

            actor.x = actor_translation.x.round
            actor.y = actor_translation.y.round

            actor.rot -= actor_rotation_delta

            log vec2(actor.x, actor.y)
            actor.remove_behavior :gravity


            actor.emit :hit_bottom

            actor.accel.x = 0
            actor.accel.y = 0
            actor.vel.x = 0
            actor.vel.y = 0

            break
          end
        end

      else
        actor.x += actor.vel.x 
        actor.y += actor.vel.y
      end

      # DEBUG!
      vb = Rect.new(viewport.boundary)
      actor.y = 10 if actor.y > vb.bottom
      actor.y = 600 if actor.y < vb.y
      actor.x = 0 if actor.x > vb.right
      actor.x = vb.right-100 if actor.x < vb.x
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

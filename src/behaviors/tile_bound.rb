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

        collision = collisions.first

        point_index = collision[:point_index]
        fudge = 0.01

        face_normal = FACE_ROTATIONS[collision[:tile_face]]
        unless map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)

          hit = collision[:hit]
          hit_vector = vec2(hit[0], hit[1])


          actor_loc = vec2(actor.x, actor.y)

          pre_rotated_bottom = actor_loc + vec2(0,actor.height/2.0)
          rotated_bottom = pre_rotated_bottom.rotate actor.rot

          actor_translation = actor_loc - rotated_bottom
          actor_rotation = face_normal.angle_with(actor_translation)

          actor.x += actor_translation.x
          actor.y += actor_translation.y

          actor.rot += actor_rotation
        end

        actor.emit :hit_bottom

        actor.accel.x = 0
        actor.accel.y = 0
        actor.vel.x = 0
        actor.vel.y = 0

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

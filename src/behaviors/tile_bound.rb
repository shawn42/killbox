define_behavior :tile_bound do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    actor.when :tile_collisions do |collisions|
      if collisions
        map = actor.map.map_data
        new_x = nil
        new_y = nil

        hit_top = false
        hit_bottom = false
        hit_left = false
        hit_right = false

        collisions.each do |collision|
          point_index = collision[:point_index]
          fudge = 0.01
          case collision[:tile_face]
          when :top
            # some edge case here
            if point_index == 4 || point_index == 5
              unless map_inspector.solid?(map, collision[:row] - 1, collision[:col])
                new_y = (collision[:hit][1] - actor.height - fudge)
                hit_bottom = true
              end
            end
          when :bottom
            unless map_inspector.solid?(map, collision[:row] + 1, collision[:col])
              if point_index == 0 || point_index == 1
                new_y = collision[:hit][1] + fudge
                hit_top = true
              end
            end
          when :left
            unless map_inspector.solid?(map, collision[:row], collision[:col] - 1)
              if point_index == 1 || point_index == 2 || point_index == 3 || point_index == 4
                new_x = (collision[:hit][0] - actor.width - fudge)
                hit_right = true
              end
            end
          when :right
            unless map_inspector.solid?(map, collision[:row], collision[:col] + 1)
              if point_index == 5 || point_index == 6 || point_index == 7 || point_index == 0
                new_x = collision[:hit][0] + fudge
                hit_left = true
              end
            end
          end
        end

        actor.y = new_y if new_y
        actor.x = new_x if new_x

        actor.emit :hit_top if hit_top
        actor.emit :hit_bottom if hit_bottom
        actor.emit :hit_left if hit_left
        actor.emit :hit_right if hit_right
        if hit_top || hit_bottom
          actor.accel.y = 0
          actor.vel.y = 0
        end
        if hit_left || hit_right
          actor.accel.x = 0
          actor.vel.x = 0
        end
      end

      actor.x += actor.vel.x unless hit_left || hit_right
      actor.y += actor.vel.y unless hit_top || hit_bottom

      # DEBUG!
      vb = Rect.new(viewport.boundary)
      actor.y = 10 if actor.y > vb.bottom
      actor.y = 600 if actor.y < vb.y
      actor.x = 0 if actor.x > vb.right
      actor.x = vb.right-100 if actor.x < vb.x
    end
  end
end

define_behavior :tile_bound do
  requires :map_inspector
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
            if point_index == 3 || point_index == 4
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
              if point_index == 1 || point_index == 2 || point_index == 3
                new_x = (collision[:hit][0] - actor.width - fudge)
                hit_right = true
              end
            end
          when :right
            unless map_inspector.solid?(map, collision[:row], collision[:col] + 1)
              if point_index == 4 || point_index == 5 || point_index == 0
                new_x = collision[:hit][0] + fudge
                hit_left = true
              end
            end
          end
        end

        if new_y
          actor.y = new_y
        end

        if new_x
          actor.x = new_x
        end

        actor.emit :hit_top if hit_top
        actor.emit :hit_bottom if hit_bottom
        actor.emit :hit_left if hit_left
        actor.emit :hit_right if hit_right
      end

      actor.x += actor.vel.x unless hit_left || hit_right
      actor.y += actor.vel.y unless hit_top || hit_bottom

      # DEBUG!
      if actor.y > 600
        actor.y = 100
      end
    end
  end
end

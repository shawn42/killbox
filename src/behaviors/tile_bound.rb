define_behavior :tile_bound do
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    actor.when :tile_collisions do |collisions|
      if collisions
        new_x = nil
        new_y = nil

        # for events
        hit_top = false
        hit_bottom = false
        hit_left = false
        hit_right = false

        # puts "#{collisions.size} #{collisions.inspect}"
        collisions.each do |collision|
          fudge = 0.01
          case collision[:tile_face]
          when :top
            # puts "TOP    : #{collision.inspect}"
            # some edge case here
            new_y = (collision[:hit][1] - actor.height - fudge)
            hit_bottom = true
          when :bottom
            new_y = collision[:hit][1] + fundge
            hit_top = true
          when :left
            puts "left collision #{collision} #{actor.x} #{actor.width}"
            new_x = (collision[:hit][0] - actor.width - fudge)
            hit_right = true
          when :right
            puts "right collision #{collision} #{actor.x} #{actor.width}"
            new_x = collision[:hit][0] + fudge
            hit_left = true
          end
        end

        if new_y
          # puts "moving actor from #{actor.y} to #{new_y}"
          actor.y = new_y
          actor.vel.y = 0 
          actor.accel.y = 0 
        end

        if new_x
          puts "moving actor from #{actor.x} to #{new_x}"
          actor.x = new_x
          actor.vel.x = 0 
          actor.accel.x = 0 
        end

        actor.emit :hit_top if hit_top
        actor.emit :hit_bottom if hit_bottom
        actor.emit :hit_left if hit_left
        actor.emit :hit_right if hit_right
      end

      # TODO move actor, truncate velocity if required
      # send event to tiles that collided?
      actor.x += actor.vel.x
      actor.y += actor.vel.y

      # EEK.. TODO XXX where should this live?
      actor.accel = vec2(0,0)

      # puts "actor y : #{actor.y}"
    end
  end
end

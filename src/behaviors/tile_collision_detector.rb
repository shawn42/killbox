define_behavior :tile_collision_detector do
  requires :director, :map_inspector
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    raise "bounding box required" unless actor.has_attribute? :bb
    raise "map required" unless actor.has_attribute? :map

    director.when :update do |time|
      find_collisions time
    end

    reacts_with :remove
  end

  helpers do
    include MinMaxHelpers

    def find_collisions(time)
      collisions = nil
      map = actor.map.map_data
      vel = actor.vel
      actor_rot_vel = actor.do_or_do_not(:rotation_vel) || 0
      bb = actor.bb

      rotation = degrees_to_radians(actor.rotation + actor_rot_vel)
      moved_rotated_points = actor.collision_point_deltas.map do |delta_point| 
        (delta_point).rotate(rotation) + actor.position + vel
      end

      # $big_bag = trans_bb.dup

      lines_to_check = []
      unless vel.x == 0 && vel.y == 0 && actor_rot_vel == 0
        actor.collision_points.each.with_index do |cp, i|
          from = cp.to_a
          to = moved_rotated_points[i].to_a
          lines_to_check << [from, to]
        end
      end

      if ENV['DEBUG']
        actor.has_attribute :lines
        actor.lines = lines_to_check.dup
      end

      bb_to_check = actor.predicted_bb
      map_inspector.overlap_tiles(map, bb_to_check) do |tile, row, col|

        lines_to_check.each.with_index do |line, i|
          map_inspector.line_tile_collision(map, line, row, col) do |collision|
            collisions ||= []
            collision[:point_index] = i
            collisions << collision
          end

        end


      end
      # log "bb_to_check: #{bb_to_check}" if collisions

      actor.emit :tile_collisions, collisions
    end

    def remove
      director.unsubscribe_all self
    end
  end
end

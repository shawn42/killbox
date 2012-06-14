define_behavior :tile_collision_detector do
  requires :director, :map_inspector
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    raise "bounding box required" unless actor.has_attribute? :bb
    raise "map required" unless actor.has_attribute? :map

    director.when :update do |time|
      find_collisions time
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end

  helpers do
    def find_collisions(time)
      collisions = nil
      map = actor.map.map_data
      vel = actor.vel
      bb = actor.bb
      ext_bb = bb.move vel.x, vel.y

      current_points = [ bb.tl, bb.tr, bb.br, bb.bl ]
      extrapolated_points = [ ext_bb.tl, ext_bb.tr, ext_bb.br, ext_bb.bl ]

      map_inspector.overlap_tiles(map, bb) do |tile, row, col|
        current_points.zip(extrapolated_points).each.with_index do |line, i|

          map_inspector.line_tile_collision(map, line, row, col) do |collision|
            unless collisions && collisions.any?{|c| c[:row] == collision[:row] && c[:col] == collision[:col] }
              collisions ||= []
              collision[:point_index] = i
              collisions << collision
            end
          end

        end
      end

      actor.emit :tile_collisions, collisions
    end
  end
end

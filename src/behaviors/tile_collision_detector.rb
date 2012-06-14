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
      # $debug_drawer.draw("foxy_bb") do |target|
      #   c = Color::RED
      #   target.draw_box bb.tl[0], bb.tl[1], bb.br[0], bb.br[1], c, 99_999
      # end

      map_inspector.overlap_tiles(map, bb.union(ext_bb)) do |tile, row, col|
        current_points.zip(extrapolated_points).each.with_index do |line, i|

          map_inspector.line_tile_collision(map, line, row, col) do |collision|

            l = collision[:hit]
            if l.is_a?(Array)
              if i == 1
                # $debug_drawer.draw("clipping_line #{i}") do |target|
                #   c = Color::RED
                #   target.draw_line line[0][0], line[0][1], l[0], l[1], c, 99_999
                # end
              end
            end
            # unless collisions && collisions.any?{|c| c[:row] == collision[:row] && c[:col] == collision[:col] }
              collisions ||= []
              collision[:point_index] = i
              collisions << collision
            # end
          end

        end
      end

      actor.emit :tile_collisions, collisions
    end
  end
end

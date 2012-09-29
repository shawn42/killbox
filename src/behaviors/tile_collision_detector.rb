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
    include MinMaxHelpers
    def find_collisions(time)
      collisions = nil
      map = actor.map.map_data
      vel = actor.vel
      actor_loc = vec2(actor.x, actor.y)
      actor_rot_vel = actor.do_or_do_not(:rotation_vel) || 0

      bb = actor.bb
      trans_bb = bb.move vel.x, vel.y

      # rotate the translated bb
      trans_center = vec2(trans_bb.centerx, trans_bb.centery)
      points = [
        vec2(trans_bb.l, trans_bb.t) - trans_center,
        vec2(trans_bb.r, trans_bb.t) - trans_center,
        vec2(trans_bb.r, trans_bb.b) - trans_center,
        vec2(trans_bb.l, trans_bb.b) - trans_center,
      ]
      rotation_rads = degrees_to_radians(actor.rotation + actor_rot_vel)
      rotated_points = points.map do |point|
        (rotation_rads == 0.0 ? point : point.rotate(rotation_rads)) + trans_center
      end

      rotated_points.each do |point|
        trans_bb.x = min(point.x, trans_bb.x)
        trans_bb.y = min(point.y, trans_bb.y)
        trans_bb.r = max(point.x, trans_bb.r)
        trans_bb.b = max(point.y, trans_bb.b)
      end

      lines_to_check = actor.collision_point_deltas.map do |point|
        rotation = degrees_to_radians(actor.rotation + actor_rot_vel)
        rotated_point = (rotation == 0.0 ? point : point.rotate(rotation))
        from = (actor_loc + rotated_point).to_a
        to = (actor_loc + rotated_point + vel).to_a
        [from, to]
      end
      actor.has_attribute :lines
      actor.lines = lines_to_check.dup


      $logs ||= []
      $big_bag = bb.union(trans_bb).inflate(actor.width*2,actor.height*2)
      $logs << ".... checking .... #{$big_bag}"
      map_inspector.overlap_tiles(map, $big_bag) do |tile, row, col|
        lines_to_check.each.with_index do |line, i|
          map_inspector.line_tile_collision(map, line, row, col) do |collision|
            collisions ||= []
            collision[:point_index] = i
            collisions << collision
          end

        end
      end

      actor.emit :tile_collisions, collisions
    end
  end
end

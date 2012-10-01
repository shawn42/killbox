define_behavior :tile_oriented do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    actor.has_attribute :ground_normal, vec2(0, -1)

    actor.when :tile_collisions do |collisions|
      if ENV['DEBUG']
        $logs ||= []
        $logs << "#{actor.respond_to?(:name) ? actor.name : actor.object_id} #{collisions}"
      end
      if collisions
        map = actor.map.map_data
        actor_loc = vec2(actor.x, actor.y)

        interesting_collisions = collisions.select do |collision|
          face_normal = FACE_NORMALS[collision[:tile_face]]
          # no tile next to
          face_normal && !map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)
        end
        if ENV['DEBUG'] && interesting_collisions.empty?
          $logs ||= []

          $logs[-60..-1].each do |l|
            log l
          end
          # binding.pry
        end

        # get collision that would occur first
        closest_collision = interesting_collisions.min_by do |collision|
          hit = collision[:hit]
          hit_vector = vec2(hit[0], hit[1])
          actor_loc = vec2(actor.x, actor.y)
          (hit_vector - actor_loc).magnitude
        end


        if closest_collision
          face_normal = FACE_NORMALS[closest_collision[:tile_face]]
          raise "Y NO COL FACE?" if closest_collision[:tile_face].nil?
          raise "Y NO FACE?" if face_normal.nil?
          actor.ground_normal = face_normal 

          set_actor_rotation closest_collision[:tile_face]
          clear_actor_velocity
          set_actor_location closest_collision
          actor.emit :hit_bottom
        else
          apply_actor_velocities
          # log "actor rotating from #{actor.rotation} += #{radians_to_degrees(actor_rotation_delta)}"
          # actor.rotation = normalize_angle(actor.rotation + radians_to_degrees(actor_rotation_delta))
        end
      else
        apply_actor_velocities
      end

    end

    reacts_with :remove

  end

  helpers do
    FACE_NORMALS = {
      top:    vec2(0, -1),
      bottom: vec2(0, 1),
      left:   vec2(-1, 0),
      right:  vec2(1, 0),
    } unless defined? FACE_NORMALS
    ROTATIONS = {
      top:    0,
      bottom: 180,
      left:   270,
      right:  90
    } unless defined? ROTATIONS

    def apply_actor_velocities
      actor.rotation = actor.rotation + actor.rotation_vel
      new_x = (actor.x + actor.vel.x)
      new_y = (actor.y + actor.vel.y)

      # tile_x = (new_x / 16).floor
      # tile_y = (actor.y / 16).floor + 1
      # map = actor.map.map_data

      if ENV['DEBUG']
        $logs ||= []
        $logs << "#{actor.respond_to?(:name) ? actor.name : actor.object_id} #{actor.x},#{actor.y} #{actor.vel}:#{actor.rotation_vel} (#{new_x},#{new_y})"
      end

      actor.x += actor.vel.x 
      actor.y += actor.vel.y
    end

    def set_actor_rotation(tile_face)
      actor.rotation_vel = 0
      actor.rotation = ROTATIONS[tile_face]
    end

    def set_actor_location(collision)
      tile_row = collision[:row] 
      tile_col = collision[:col] 

      # TODO move to map inspector?
      map = actor.map.map_data
      cps = actor.collision_points
      tile_size = map.tile_size
      actor_loc = vec2(actor.x, actor.y)

      collision_point_delta = actor_loc - cps[5]
      case collision[:tile_face]
      when :top
        lower_left_target = vec2(tile_col * tile_size, tile_row * tile_size - 1)
        new_loc = lower_left_target + collision_point_delta
        new_loc.y = new_loc.y.floor
        actor.y = new_loc.y
      when :bottom
        lower_left_target = vec2((tile_col + 1) * tile_size, (tile_row + 1) * tile_size + 1)
        new_loc = lower_left_target + collision_point_delta
        new_loc.y = new_loc.y.ceil
        actor.y = new_loc.y
      when :left
        lower_left_target = vec2(tile_col * tile_size - 1 , tile_row * tile_size)
        new_loc = lower_left_target + collision_point_delta
        new_loc.x = new_loc.x.floor
        actor.x = new_loc.x
      when :right
        lower_left_target = vec2((tile_col + 1) * tile_size + 1, tile_row * tile_size)
        new_loc = lower_left_target + collision_point_delta
        new_loc.x = new_loc.x.ceil
        actor.x = new_loc.x
      else
        raise "cannot determin desired actor location from tile_face: #{collision[:tile_face]}"
      end

      # log vec2(actor.x, actor.y)
    end

    def clear_actor_velocity
      actor.vel = vec2(0,0)
    end

    def remove
      actor.unsubscribe_all self
    end

  end
end

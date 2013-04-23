define_behavior :tile_oriented do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    actor.has_attribute :ground_normal, vec2(0, -1)

    actor.when :tile_collisions do |collisions|
      if collisions
        # log "lines: #{actor.lines}"
        # log "COLLISIONS: #{collisions}"
        map = actor.map.map_data
        actor_loc = vec2(actor.x, actor.y)

        interesting_collisions = collisions.select do |collision|
          face_normal = FACE_NORMALS[collision[:tile_face]]
          # no tile next to
          face_normal && !map_inspector.solid?(map, collision[:row] + face_normal.y, collision[:col] + face_normal.x)
        end

        # get collision that would occur first
        closest_collision = interesting_collisions.min_by do |collision|
          hit = collision[:hit]
          hit_vector = vec2(hit[0], hit[1])
          actor_loc = vec2(actor.x, actor.y)
          (hit_vector - actor_loc).magnitude
        end


        if closest_collision
          tile_face = tile_face_to_attach_to(closest_collision)
          # log "srsly: #{tile_face.inspect}"
          face_normal = FACE_NORMALS[tile_face]

          raise "Y NO FACE?" if face_normal.nil?
          actor.ground_normal = face_normal 

          set_actor_rotation tile_face
          clear_actor_velocity
          set_actor_location tile_face, closest_collision
          actor.emit :hit_bottom
        else
          apply_actor_velocities
        end
      else
        apply_actor_velocities
      end

    end

    reacts_with :remove

  end

  helpers do
    include MinMaxHelpers
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
      new_x = (actor.x + actor.vel.x) # XXX
      new_y = (actor.y + actor.vel.y) # XXX

      actor.x += actor.vel.x 
      actor.y += actor.vel.y
    end

    def set_actor_rotation(tile_face)
      actor.rotation_vel = 0
      actor.rotation = ROTATIONS[tile_face]
    end

    def tile_face_to_attach_to(collision)
      code_to_face = {
        LineClipper::LEFT => :left,
        LineClipper::RIGHT => :right,
        LineClipper::TOP => :top,
        LineClipper::BOTTOM => :bottom,
      }

      less_interesting_outcodes = code_to_face.keys
      outcode = LineClipper.calculate_outcode(actor.x, actor.y, collision[:tile_bb])
      # log "actor loc: #{actor.x}, #{actor.y}"
      # log "TILEBB: #{collision[:tile_bb]}"
      # log "outcode: #{outcode}"
     
      if less_interesting_outcodes.include?(outcode)
        # log "LOOKUP"
        # log code_to_face[outcode]
        code_to_face[outcode]
      else
        return collision[:tile_face] if outcode == LineClipper::INSIDE

        player_vec = vec2(0,-1).rotate(-actor.rotation)
        # log "player: #{player_vec}"
        map = actor.map.map_data
        left_ok = !map_inspector.solid?(map, collision[:row] + FACE_NORMALS[:left].y, collision[:col] + FACE_NORMALS[:left].x)
        right_ok = !map_inspector.solid?(map, collision[:row] + FACE_NORMALS[:right].y, collision[:col] + FACE_NORMALS[:right].x)
        top_ok = !map_inspector.solid?(map, collision[:row] + FACE_NORMALS[:top].y, collision[:col] + FACE_NORMALS[:top].x)
        bottom_ok = !map_inspector.solid?(map, collision[:row] + FACE_NORMALS[:bottom].y, collision[:col] + FACE_NORMALS[:bottom].x)

        if outcode == (LineClipper::LEFT | LineClipper::TOP)
          return :top unless left_ok
          return :left unless top_ok

          left_ang_diff = FACE_NORMALS[:left].angle_with(player_vec)
          top_ang_diff = FACE_NORMALS[:top].angle_with(player_vec)

          left_ang_diff < top_ang_diff ? :left : :top


        elsif outcode == (LineClipper::LEFT | LineClipper::BOTTOM)
          return :bottom unless left_ok
          return :left unless bottom_ok

          left_ang_diff = FACE_NORMALS[:left].angle_with(player_vec)
          bottom_ang_diff = FACE_NORMALS[:bottom].angle_with(player_vec)
          left_ang_diff < bottom_ang_diff ? :left : :bottom

        elsif outcode == (LineClipper::RIGHT | LineClipper::TOP)
          return :top unless right_ok
          return :right unless top_ok

          right_ang_diff = FACE_NORMALS[:right].angle_with(player_vec)
          top_ang_diff = FACE_NORMALS[:top].angle_with(player_vec)
          right_ang_diff < top_ang_diff ? :right : :top

        elsif outcode == (LineClipper::RIGHT | LineClipper::BOTTOM)
          return :bottom unless right_ok
          return :right unless bottom_ok

          right_ang_diff = FACE_NORMALS[:right].angle_with(player_vec)
          bottom_ang_diff = FACE_NORMALS[:bottom].angle_with(player_vec)
          right_ang_diff < bottom_ang_diff ? :right : :bottom
        end

      end
    end

    def set_actor_location(tile_face, collision)
      tile_row = collision[:row] 
      tile_col = collision[:col] 

      # TODO move to map inspector?
      map = actor.map.map_data
      cps = actor.collision_points
      tile_size = map.tile_size
      actor_loc = vec2(actor.x, actor.y)

      collision_point_delta = actor_loc - cps[5] # cps[5] lower left (maybe set as data in actor)
      case tile_face
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
        raise "cannot determine desired actor location from tile_face: #{collision[:tile_face]}"
      end


      # fix if not standing on the tile
      axis = perp_axis(tile_face)
      actor_hw = (min(actor.bb.w, actor.bb.h) / 2).floor
      tile_hw = (tile_size / 2).floor
      max_diff = (actor_hw + tile_hw) - 1

      tile_center = vec2(tile_col * tile_size + tile_hw, tile_row * tile_size + tile_hw)
      axis_val = actor.send(axis)
      diff = axis_val - tile_center.send(axis)
      diff_dist = diff.abs

      # log "axis: #{axis}"
      # log "actor_hw: #{actor_hw}"
      # log "tile_hw: #{tile_hw}"
      # log "tile_center: #{tile_center}"
      # log "axis_val: #{axis_val}"

      # log "diff_dist: #{diff_dist} max_diff: #{max_diff}"
      if diff_dist > max_diff

        required_shift = diff_dist - max_diff
        sign = required_shift < 0 ? -1 : 1
        required_shift = required_shift.abs.ceil * sign


        shift_direction = diff < 0 ? 1 : -1
        actor.send("#{axis}=", axis_val + shift_direction * required_shift)
        # log "shifting on #{axis} by #{shift_direction * required_shift}"
      end

    end

    def perp_axis(tile_face)
      {
        top: :x,
        bottom: :x,
        left: :y,
        right: :y,
      }[tile_face]
    end

    def clear_actor_velocity
      actor.vel = vec2(0,0)
      actor.accel = vec2(0,0)
      actor.rotation_vel = 0
    end

    def remove
      actor.unsubscribe_all self
    end

  end
end

define_behavior :looker do
  requires :director

  setup do
    # in pixels
    viewport = actor.do_or_do_not :viewport

    actor.has_attributes look_distance: 100,
                         flip_h: false

    input = actor.input
    input.when :look_left do
      actor.flip_h = true
    end
    input.when :look_right do
      actor.flip_h = false
    end

    if viewport
      director.when :update do |t_ms, time_in_sec|
        update_look_point time_in_sec
      end
    end
  end


  helpers do
    include MinMaxHelpers

    def look_directions 
      {
      left: vec2(-1,0),
      right: vec2(1,0),
      up: vec2(0,-1),
      down: vec2(0,1)
      }
    end

    def update_look_point(time_secs)
      input = actor.input

      look_vector = if input.look_left?
        look_directions[:left]
      elsif input.look_right?
        look_directions[:right]
      elsif input.look_up?
        look_directions[:up]
      elsif input.look_down?
        look_directions[:down]
      end

      viewport = actor.viewport
      current_vec = vec2(viewport.follow_offset_x, viewport.follow_offset_y)
      if look_vector 
        rot = actor.do_or_do_not(:rotation) || 0
        offset_vec = current_vec - look_vector.rotate_deg(rot) * actor.look_distance * time_secs

        offset_vec.magnitude = actor.look_distance if offset_vec.magnitude > actor.look_distance

        viewport.follow_offset_x = offset_vec.x
        viewport.follow_offset_y = offset_vec.y
      else
        current_magnitude = current_vec.magnitude 
        magnitude_to_move_toward_player = actor.look_distance * time_secs
        current_vec.magnitude = max(current_magnitude - magnitude_to_move_toward_player, 0)

        current_vec = vec2(0,0) if current_vec.magnitude < 1

        viewport.follow_offset_x = current_vec.x
        viewport.follow_offset_y = current_vec.y
      end

    end

  end
end

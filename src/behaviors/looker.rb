define_behavior :looker do
  requires :director

  setup do
    # in pixels
    actor.has_attributes look_distance: 150,
                         flip_h: false, 
                         look_vector: Look::DIRECTIONS[:left]

    input = actor.controller
    input.when(:look_left) { actor.flip_h = true }
    input.when(:look_right) { actor.flip_h = false }

    director.when :update do |t_ms, time_in_sec|
      if actor.do_or_do_not :viewport
        update_look_point time_in_sec
      end
    end
  end

  remove do
    actor.controller.unsubscribe_all self
    director.unsubscribe_all self
  end


  helpers do
    include MinMaxHelpers

    def update_look_point(time_secs)
      input = actor.controller

      look_vector = if input.look_left?
        Look::DIRECTIONS[:left]
      elsif input.look_right?
        Look::DIRECTIONS[:right]
      elsif input.look_up?
        Look::DIRECTIONS[:up]
      elsif input.look_down?
        Look::DIRECTIONS[:down]
      end

      viewport = actor.viewport
      current_vec = vec2(viewport.follow_offset_x, viewport.follow_offset_y)
      if look_vector 
        actor.look_vector = look_vector
        rot = actor.do_or_do_not(:rotation) || 0
        offset_vec = current_vec - look_vector.rotate_deg(rot) * actor.look_distance * time_secs

        offset_vec.magnitude = actor.look_distance if offset_vec.magnitude > actor.look_distance

        viewport.follow_offset_x = offset_vec.x
        viewport.follow_offset_y = offset_vec.y
      end

    end

  end
end

define_behavior :looker do
  requires :director

  setup do
    # in pixels
    actor.has_attributes look_distance: 100,
                         flip_h: false

    director.when :update do |time_in_ms|
      fade_look_point time_in_ms
    end

    input = actor.input
    input.when :look_left do
      look look_directions[:left]
      actor.flip_h = true
    end
    input.when :look_right do
      look look_directions[:right]
      actor.flip_h = false
    end
    input.when :look_up do
      look look_directions[:up]
    end
    input.when :look_down do
      look look_directions[:down]
    end
  end


  helpers do
    def look_directions 
      {
      left: vec2(-1,0),
      right: vec2(1,0),
      up: vec2(0,-1),
      down: vec2(0,1)
      }
    end

    def fade_look_point(time_ms)
    end

    def look(look_vector)
      # TODO do we need to smooth this out?
      rot = actor.do_or_do_not(:rotation) || 0
      vp_offset = -look_vector.rotate_deg(rot) * actor.look_distance

      actor.viewport.follow_offset_x = vp_offset.x
      actor.viewport.follow_offset_y = vp_offset.y
    end

  end
end

define_behavior :gravity_manipulator do
  requires :input_manager, :viewport
  setup do
    actor.has_attributes gravity: opts[:dir],
                         rot: 0

    input_manager.reg :down, KbG do
      if actor.has_behavior?(:gravity)
        remove_behavior(:gravity)
      else
        add_behavior(:gravity)
      end
    end

    input_manager.reg :down, KbR do
      actor.gravity.rotate!(Math::HALF_PI)
      actor.vel = vec2(0,0)
      viewport.rotation = radians_to_degrees(Math::HALF_PI - actor.gravity.a)
      # actor.rot = radians_to_degrees(-(Math::HALF_PI - actor.gravity.a))
    end
  end
end

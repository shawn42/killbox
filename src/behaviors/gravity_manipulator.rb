define_behavior :gravity_manipulator do
  requires :input_manager, :viewport
  setup do
    actor.has_attributes gravity: opts[:dir],
                         rot: 0

    input_manager.reg :down, KbG do
      actor.gravity.rotate!(Ftor::HALF_PI)
      actor.vel = vec2(0,0)
      viewport.rotation = radians_to_degrees(Ftor::HALF_PI - actor.gravity.a)
      # actor.rot = radians_to_degrees(-(Ftor::HALF_PI - actor.gravity.a))
    end
  end
end

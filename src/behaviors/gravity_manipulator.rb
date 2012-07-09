define_behavior :gravity_manipulator do
  requires :input_manager
  setup do
    actor.has_attributes gravity: opts[:dir]

    input_manager.reg :down, KbG do
      actor.gravity.rotate!(Ftor::HALF_PI)
    end
  end
end

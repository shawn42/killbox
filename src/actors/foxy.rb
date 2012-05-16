define_actor :foxy do
  has_attributes view: :graphical_actor_view
  has_behaviors do
    positioned
    animated
    input_stater(
      KbLeft => :move_left,
      KbRight => :move_right,
      KbUp => :attempt_jump
    )
    mover speed: 0.14
  end

end



define_actor :black_hole do
  has_behaviors do
    layered ZOrder::BackgroundEffects
    animated_with_spritemap file: 'trippers/black_hole.png', rows: 1, cols: 3, actions: { idle: 0..1 }
    emits_gravity
    graphical
  end

  behavior do
    requires :director

    setup do
      actor.has_attributes rotation: 0, rotation_vel: 1.3
      director.when :update do |time_delta_ms|
        actor.rotation += actor.rotation_vel
      end
    end
  end
end

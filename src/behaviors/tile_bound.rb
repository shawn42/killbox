define_behavior :tile_bound do
  setup do
    actor.has_attributes vel: vec2(0,0)
    actor.when :tile_collisions do |collision_data|
      collision_data[:collisions].each do |collision|
      end
      # TODO move actor, truncate velocity if required
      # send event to tiles that collided?
    end
  end
end

define_behavior :tile_bound do
  setup do
    raise "vel required" unless actor.has_attribute? :vel
    actor.when :tile_collisions do |collision_data|
      # puts collision_data.inspect
      # TODO move actor, truncate velocity if required
      # send event to tiles that collided?
      actor.x += actor.vel.x
      actor.y += actor.vel.y

      # EEK.. TODO XXX where should this live?
      actor.accel = vec2(0,0)
    end
  end
end

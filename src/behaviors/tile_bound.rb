define_behavior :tile_bound do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel

    actor.when :tile_collisions do |collisions|
      actor.vel.x = 0
      actor.vel.y = 0
    end

    reacts_with :remove
  end

  remove do
    actor.unsubscribe_all self
  end
end

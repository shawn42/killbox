define_behavior :tile_bound do
  requires :map_inspector, :viewport
  setup do
    raise "vel required" unless actor.has_attribute? :vel

    actor.when :tile_collisions do |collisions|
      if collisions
        actor.vel.x = 0
        actor.vel.y = 0
      else

        actor.x += actor.vel.x 
        actor.y += actor.vel.y
      end
    end
  end
end

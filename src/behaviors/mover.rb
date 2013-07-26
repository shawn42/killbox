# Moves the actor by velocity and rot_vel
define_behavior :mover do

  setup do
    actor.has_attributes rotation_vel: 0

    actor.when :no_tile_collisions do
      actor.rotation = actor.rotation + actor.rotation_vel

      actor.update_attributes x: actor.x + actor.vel.x,
        y: actor.y + actor.vel.y
    end
  end


  remove do
    actor.unsubscribe_all self
  end
end

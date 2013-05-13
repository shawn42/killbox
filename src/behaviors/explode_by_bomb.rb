define_behavior :explode_by_bomb do
  requires :bomb_coordinator, :stage
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :remove, :esplode
  end

  helpers do
    def esplode(bomb, distance)
      if distance < (bomb.radius * 0.666)
        actor.react_to :play_sound, :bomb
        actor.player = bomb.player
        actor.remove
        actor.emit :boom

      else
        blast_vel = (actor.position - bomb.position).unit * 5
        actor.vel += blast_vel if actor.do_or_do_not(:vel)
      end
    end

    def remove
      bomb_coordinator.unregister_bombable actor
    end

  end
end

define_behavior :explode_by_bomb do
  requires :bomb_coordinator, :stage, :map_inspector
  setup do
    bomb_coordinator.register_bombable actor

    reacts_with :esplode
  end

  remove do
    bomb_coordinator.unregister_bombable actor
  end

  helpers do
    def esplode(bomb, distance)
      if distance < (bomb.radius * 0.666) && map_inspector.line_of_sight?(actor, bomb)
        actor.react_to :play_sound, :bomb
        actor.player = bomb.player
        actor.remove
        actor.emit :boom

      else
        if actor.do_or_do_not(:vel)
          blast_vel = (actor.position - bomb.position).unit * 5
          actor.vel += blast_vel 
        end
      end
    end
    
  end
end

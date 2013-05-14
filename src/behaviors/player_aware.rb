define_behavior :player_aware do
  requires :timer_manager, :stage, :map_inspector

  setup do
    actor.has_attributes player_proximity_range: (actor.do_or_do_not(:player_proximity_range) || opts[:player_proximity_range] || 100)

    timer_manager.add_timer proximity_check_timer_name, 100 do
      actor.emit :player_near if player_near?
    end

    reacts_with :remove
  end

  helpers do
    def player_near?
      stage.players.any? do |player| 
        # WTF, shouldn't have to set this
        actor.position = vec2(actor.x, actor.y)
        (player.position - actor.position).magnitude < actor.player_proximity_range && 
          map_inspector.line_of_sight?(actor, player)
      end
    end

    def remove
      timer_manager.remove_timer proximity_check_timer_name
    end

    def proximity_check_timer_name; "proximity_check_#{object_id}"; end
  end
end

define_behavior :shielded do
  requires :resource_manager, :timer_manager
  setup do
    actor.has_attributes shield_time_in_ms: opts[:shield_time_in_ms] || 1_200,
                         shields_up: false

    actor.input.when(:shields_up) { shields_up }

    reacts_with :remove
  end

  helpers do
    UNSHIELDED_BEHAVIORS = [:jump, :shooter, :bomber, :tile_oriented] unless defined? UNSHIELDED_BEHAVIORS
    def shield_up_sound
      actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
    end

    def shields_up
      unless actor.shields_up?
        actor.shields_up = true
        timer_manager.add_timer "shields_down_#{object_id}", actor.shield_time_in_ms, false do
          shields_down
        end

        shield_up_sound
        UNSHIELDED_BEHAVIORS.each do |beh|
          remove_behavior beh
        end
        add_behavior :tile_bouncer
      end
    end

    def shields_down
      actor.shields_up = false

      remove_behavior :tile_bouncer
      UNSHIELDED_BEHAVIORS.each do |beh|
        add_behavior beh
      end
    end

    def remove
      timer_manager.remove_timer "shields_down_#{object_id}"
    end

  end


end

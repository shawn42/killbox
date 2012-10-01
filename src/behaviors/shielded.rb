define_behavior :shielded do
  requires :resource_manager, :timer_manager
  setup do
    actor.has_attributes shield_time_in_ms: opts[:shield_time_in_ms] || 1_200,
                         shield_image: resource_manager.load_image('shield.png'),
                         shields_up: false

    actor.input.when(:shields_up) { shields_up }

    reacts_with :remove
  end

  helpers do
    def shield_up_sound
      actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
    end

    def shields_up
      unless actor.shields_up?
        actor.shields_up = true
        timer_manager.add_timer "shields_down_#{object_id}", actor.shield_time_in_ms, false do
          shields_down
        end

        # TODO use its own sound?
        shield_up_sound
        remove_behavior :tile_oriented
        add_behavior :tile_bouncer
      end
    end

    def shields_down
      actor.shields_up = false

      remove_behavior :tile_bouncer
      add_behavior :tile_oriented
    end

    def remove
      timer_manager.remove_timer "shields_down_#{object_id}"
    end

  end


end

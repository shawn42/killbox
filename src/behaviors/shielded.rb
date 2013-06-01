define_behavior :shielded do
  requires :resource_manager, :timer_manager
  setup do
    actor.has_attributes shield_time_in_ms: opts[:shield_time_in_ms] || 1_200,
                         shield_recharge_time_in_ms: opts[:shield_recharge_time_in_ms] || 600,
                         shields_up: false,
                         shields_recharging: false

    actor.input.when(:shields_up) { shields_up }

    reacts_with :remove
  end

  helpers do
    def unshielded_behaviors 
      [:accelerator, :jump, :slicer, :shooter, :bomber, :friction, :grounded,
        :tile_oriented, :die_by_bomb, :die_by_bullet, :die_by_sword, :disoriented_by_bombs,
        :pulled_by_black_hole ]
    end

    def shielded_behaviors 
      [:tile_bouncer, :absorb_bullet]
    end

    def shield_up_sound
      actor.react_to :play_sound, :shield
    end

    def shields_up
      unless actor.shields_recharging? or actor.shields_up?
        actor.shields_up = true
        actor.action = :jumping
        timer_manager.add_timer shield_enabled_timer_name, actor.shield_time_in_ms, false do
          shields_down
        end

        shield_up_sound
        unshielded_behaviors.each do |beh|
          remove_behavior beh
        end
        shielded_behaviors.each do |beh|
          add_behavior beh
        end
      end
    end

    def shields_down
      actor.shields_up = false
      recharge_shield

      shielded_behaviors.each do |beh|
        remove_behavior beh
      end
      unshielded_behaviors.each do |beh|
        add_behavior beh
      end
    end

    def recharge_shield
      actor.shields_recharging = true
      timer_manager.add_timer shield_recharging_timer_name, actor.shield_recharge_time_in_ms, false do
        actor.shields_recharging = false
      end
    end

    def remove
      timer_manager.remove_timer shield_enabled_timer_name
      timer_manager.remove_timer shield_recharging_timer_name
      actor.input.unsubscribe_all self
    end

    def shield_enabled_timer_name
      "#{object_id}:shield_enabled"
    end

    def shield_recharging_timer_name
      "#{object_id}:shield_recharging"
    end

  end


end

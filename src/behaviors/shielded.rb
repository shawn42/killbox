define_behavior :shielded do
  requires :director, :resource_manager
  setup do
    actor.has_attributes shield_time: opts[:shield_time] || 0.8,
                         shields_up: false,
                         shield_timer: 0.0
    actor.has_attributes :shield_image
                        
    director.when :update do |time, time_secs|
      update_shields time_secs
    end
    actor.shield_image = resource_manager.load_image 'shield.png'
    actor.input.when(:shields_up) { actor.shields_up = !actor.shields_up}

    actor.when :remove_me do
      remove
    end

    reacts_with :remove
  end

  helpers do
    def shield_up_sound
      actor.react_to :play_sound, (rand(2)%2 == 0 ? :jump1 : :jump2)
    end

    def update_shields(t)
      if actor.shields_up
        if actor.input.shields_up?
          shield_up_sound
          actor.emit :shields
        end

        actor.shield_timer += t
        if actor.shield_timer > actor.shield_time
          shield_up_sound
          actor.shields_up = false
          actor.shield_timer = 0.0
        end

      else
        actor.shield_timer = 0.0
      end
    end

    def remove
      director.unsubscribe_all self
    end
  end


end

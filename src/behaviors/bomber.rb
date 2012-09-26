define_behavior :bomber do
  requires :stage, :director
  setup do
    # lets start with infinite bombs, fixed vel
    actor.has_attributes bomb_charge: 0,
                         was_charging_bomb: false
                        
    director.when :first do |time, time_secs|
      update_bombing time_secs
    end

  end

  helpers do

    def update_bombing(time_secs)
      input = actor.input
      if actor.was_charging_bomb? && !input.charging_bomb?
        actor.was_charging_bomb = false
        bomb_if_able time_secs
      elsif input.charging_bomb?
        actor.was_charging_bomb = true
      end
    end

    def bomb_if_able(time_secs)
      puts "BOMBING"
      bomb_power = 200 * time_secs
      bomb_vel = vec2(1,0).rotate(degrees_to_radians(actor.rotation)) * bomb_power
      stage.create_actor :bomb, player: actor, x: actor.x, y: actor.y, map: actor.map, vel: bomb_vel
      actor.react_to :play_sound, :shoot

      # TODO Add some rotational force
    end

  end

end


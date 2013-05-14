define_actor :land_mine do
  
  has_behaviors do
    positioned
    audible
    layered ZOrder::PlayerDecoration
    animated_with_spritemap file: 'trippers/props.png', rows: 3, cols: 6, actions: { idle: 0 }
    bound_by_box
    bomb_collision_points
    explode_by_bomb
    explode_by_bullet
  end

  behavior do
    requires :timer_manager, :stage

    setup do
      reacts_with :remove

      land_mine_arm_delay = opts[:land_mine_arm_delay] || 1_500
    
      actor.has_attributes(
        force: 8, # force of the effect at 0 distance (impulse will be force/distance)
        radius: 200, # radius of effect - the distance at which the effect's influence will drop to zero
        armed: false
      )
      actor.react_to :play_sound, :bomb_tick 
      actor.when :player_near do
        actor.react_to :play_sound, :bomb
        actor.emit :boom
        actor.remove
      end
      actor.when :boom do
        make_shrapnel
      end

      timer_manager.add_timer arm_me_timer_name, land_mine_arm_delay, false do
        arm_and_register
        add_behavior :player_aware
      end
    end

    helpers do
      def arm_me_timer_name; "arm_me_#{object_id}"; end

      def arm_and_register
        actor.armed = true
        actor.react_to :play_sound, :bomb_tick 
      end

      def remove
        actor.unsubscribe_all self
        timer_manager.remove_timer arm_me_timer_name
      end

      # TODO pull into common place?
      def make_shrapnel(args={})
        force = args[:force] || vec2(0,0)
        count = args[:count] || 30
        count.times do
          vel = vec2(3,0).rotate!(degrees_to_radians(rand(359))) * rand(4)
          stage.create_actor :shrapnel, x: actor.x, y: actor.y, vel: vel + force, map: actor.map, size: rand(8), color: Color::GRAY
        end
      end
    end
  end

  view do
    draw do |target, x_off, y_off, z|
      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      rot = normalize_angle(actor.rotation)

      img = actor.image
      #target.fill offset_x, offset_y, offset_x+2, offset_y+2, Color::YELLOW, z
      target.draw_rotated_image img, offset_x, offset_y, z, rot#, 0.5, 0.5, x_scale

      if ENV['DEBUG']
        target.draw_circle offset_x, offset_y, 100, Color::WHITE, ZOrder::PlayerDecoration
      end
      
    end
  end
end

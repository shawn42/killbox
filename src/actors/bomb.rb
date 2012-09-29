define_actor :bomb do

  has_behaviors do
    positioned
    audible
    layered ZOrder::Projectile
    animated_with_spritemap file: 'bomb.png', rows: 1, cols: 2, actions: {idle: 0..1}
    bound_by_box
    tile_bouncer
    tile_collision_detector
    trivial_collision_point
  end

  behavior do
    requires :timer_manager

    setup do
      reacts_with :remove

      setup_timers
    end

    helpers do
      def remove
        timer_name = "#{object_id}_bomb_tick"
        timer_manager.remove_timer timer_name
      end

      def setup_timers
        timer_name = "#{object_id}_bomb_tick"
        timer_tick_acculation = 0
        interval = 30
        next_beep = 800
        timer_manager.add_timer timer_name, interval do
          if timer_tick_acculation > next_beep
            actor.react_to :play_sound, :bomb_tick 
            timer_tick_acculation = 0
            next_beep = next_beep * 0.8
          else
            timer_tick_acculation += interval
          end
        end

        timer_manager.add_timer "#{object_id}_bomb_death", 4_000, false do
          actor.react_to :play_sound, :bomb
          actor.remove
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
    end
  end
end

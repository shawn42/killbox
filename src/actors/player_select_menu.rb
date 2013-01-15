define_actor :player_select_menu do
  behavior do
    requires :input_manager, :stage
    setup do
      actor.has_attributes player_count: 2,
                           label_width: 80

      font = "vigilanc.ttf"
      font_size = 80
      label_opts = {y: actor.y, font_name: font, font_size: font_size, color: [222, 135, 170]}
      label_x = actor.x

      4.times do |i|
        stage.create_actor(:label, label_opts.merge(text: i+1, x: label_x))
        label_x += actor.label_width
      end

      input_manager.reg :down, KbReturn do
        actor.emit :start, actor.player_count
      end

      input_manager.reg :down, KbRight do
        actor.player_count = (actor.player_count % 4) + 1
      end
    
      input_manager.reg :down, KbLeft do
        actor.player_count = ((actor.player_count-2)%4)+1
      end

      input_manager.reg :down, Kb1 do actor.emit :start, 1 end
      input_manager.reg :down, Kb2 do actor.emit :start, 2 end
      input_manager.reg :down, Kb3 do actor.emit :start, 3 end
      input_manager.reg :down, Kb4 do actor.emit :start, 4 end

      # probably need to clean up event
    end
    helpers do
      include MinMaxHelpers
    end


  end

end

define_actor_view :player_select_menu_view do
  requires :resource_manager
  setup do
    @menu_indicator = resource_manager.load_image 'trippers/shield.png'
  end

  draw do |target, x_off, y_off, z|
    if actor.do_or_do_not :x
      x = actor.x + actor.label_width * (actor.player_count - 1) - 20
      target.draw_image @menu_indicator, x, actor.y + 10, ZOrder::HudText
    end
  end
end



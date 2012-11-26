define_actor :menu do

  behavior do
    requires :input_manager, :stage
    setup do
      actor.has_attributes labels: [],
                           current_selected_index: 0,
                           player_count: 4

      # TODO center each label?
      actor.when :current_selected_index_changed do 
        update_highlight
      end
      actor.when :player_count_changed do 
        update_highlight
      end

      input_manager.reg :down, KbUp do
        actor.current_selected_index = max(actor.current_selected_index - 1, 0)
      end
      input_manager.reg :down, KbDown do
        actor.current_selected_index = min(actor.current_selected_index + 1, menu_items.size - 1)
      end
      input_manager.reg :down, KbRight do
        actor.player_count = min(actor.player_count + 1, 4) if actor.current_selected_index == 1
      end
      input_manager.reg :down, KbLeft do
        actor.player_count = max(actor.player_count - 1, 1) if actor.current_selected_index == 1
      end
      input_manager.reg :down, KbReturn do
        actor.emit :start, actor.player_count if actor.current_selected_index == 0
      end

      menu_items.each.with_index do |item, i|
        actor.labels << stage.create_actor(:label, text: item, x: actor.x, y: actor.y, font_size: 50)
      end
      update_highlight
    end

    helpers do
      include MinMaxHelpers

      # TODO make an actual menu item class that can respond to key presses..
      # ie: left, right, enter
      def menu_items
        [ "Start",
          "Players: #{actor.player_count}"
        ]
      end

      def update_highlight
        y = actor.y
        actor.labels.each.with_index do |label, i|
          label.font_size = i == actor.current_selected_index ? 70 : 50
          label.y = y
          label.text = menu_items[i]

          y += label.font_size
        end

      end
    end
  end
end

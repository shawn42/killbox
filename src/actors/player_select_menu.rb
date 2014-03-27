define_actor :player_select_menu do
  behavior do
    requires :input_manager, :stage
    setup do
      actor.has_attributes selected_index: 1,
                           label_width: 80,
                           items: []

      font_size = 80
      label_opts = {y: actor.y, font_size: font_size, color: Colors.pink }
      label_x = actor.x

      4.times do |i|
        value = i+1
        actor.items << stage.create_actor(:menu_item, label_opts.merge(value: value, text: value, x: label_x, selected: i == 1))
        label_x += actor.label_width
      end

      actor.items << stage.create_actor(:menu_item, label_opts.merge(value: :setup_controls, text: "Controls", x: actor.x, y: 900))

      input_manager.reg :down, KbReturn do
        actor.emit :selected, actor.items[actor.selected_index].value
      end

      input_manager.reg :down, KbRight do
        actor.selected_index = (actor.selected_index + 1) % actor.items.size
        actor.items.each.with_index do |item, i|
          item.selected = i == actor.selected_index
        end
      end
    
      input_manager.reg :down, KbLeft do
        actor.selected_index = (actor.selected_index-1)%actor.items.size
        actor.items.each.with_index do |item, i|
          item.selected = i == actor.selected_index
        end
      end

      input_manager.reg :down, KbDown do
        actor.selected_index = actor.items.size-1
        actor.items.each.with_index do |item, i|
          item.selected = i == actor.selected_index
        end
      end

      input_manager.reg :down, KbUp do
        actor.selected_index = 0
        actor.items.each.with_index do |item, i|
          item.selected = i == actor.selected_index
        end
      end

      input_manager.reg :down, Kb1 do actor.emit :selected, 1 end
      input_manager.reg :down, Kb2 do actor.emit :selected, 2 end
      input_manager.reg :down, Kb3 do actor.emit :selected, 3 end
      input_manager.reg :down, Kb4 do actor.emit :selected, 4 end

      input_manager.reg :down, KbC do actor.emit :selected, :setup_controls end

      reacts_with :remove
    end

    helpers do
      def remove
        input_manager.unsubscribe_all self
      end
    end
  end

end


# 
# define_menu do
#   menu_items do
#     item("Start") do
#       on(KbRight) ...
#     end
#   end
# end
# 


define_actor :menu do

  behavior do
    requires :input_manager, :stage
    setup do
      actor.has_attributes title_labels: [],
                           menu_labels: [],
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
        actor.menu_labels << stage.create_actor(:label, text: item, x: actor.x, y: actor.y, font_size: 50)
      end
      update_highlight

      # add title for game on the menu screen
      print_menu_header "Foxy", "a multi-player, same keyboard, action game."

      # add some help message for game on the menu screen
      print_menu_help_text "Game Controls","A -> Move Left, D -> Move Right, W -> Look Up, V -> Shield Up/Dn, N -> Jump, M -> Throw Bomb"
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
        actor.menu_labels.each.with_index do |label, i|
          label.font_size = i == actor.current_selected_index ? 70 : 50
          label.y = y
          label.text = menu_items[i]

          y += label.font_size
        end

      end

      def print_menu_header(title, sub_title)
        print_menu_text(title, 80, 100, 10)
        print_menu_text(sub_title, 30, 100, 100)
      end

      def print_menu_help_text(title, text)
        print_menu_text(title, 60, 100, actor.y + 400)
        print_menu_text(text, 30, 100, actor.y + 470)
      end

      def print_menu_text(text, size, x, y)
        actor.title_labels << stage.create_actor(:label, text: text, x: x, y: y, font_size: size)
      end
    end
  end
end

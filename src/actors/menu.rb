define_actor :menu do
  has_behaviors do
    positioned
    sized
    labeled
    selectable
    menu
    outlined
  end

  view do 
    draw do |target, x_offset, y_offset, z|
      x = actor.x + x_offset
      y = actor.y + y_offset
      w = actor.do_or_do_not(:w)
      h = actor.do_or_do_not(:h)

      color = nil
      width = nil
      
      if w && h
        if actor.selected?
          color, width = get_border('selected')
        elsif actor.active?
          color, width = get_border('active')
        else
          color, width = get_border('default')
        end

        if color and width
          [*0..width-1].to_a.each do |offset|
            target.draw_box x + offset, y + offset, x + w - offset, y + h - offset, color, z
          end
        end
      end
    end
    helpers do
      def get_border(state)
        state_sym = state.to_sym
        if actor.border and actor.border[state_sym]
          color = actor.border[state_sym][:color] || Color::WHITE
          width = actor.border[state_sym][:width] || 1
          return color, width
        else
          return nil, nil
        end
      end
    end
  end
end
# define_actor :menu do
# 
#   behavior do
#     requires :input_manager, :stage
#     setup do
#       actor.has_attributes title_labels: [],
#                            menu_labels: [],
#                            current_selected_index: 0,
#                            player_count: 4
# 
#       # TODO center each label?
#       actor.when :current_selected_index_changed do 
#         update_highlight
#       end
#       actor.when :player_count_changed do 
#         update_highlight
#       end
# 
#       input_manager.reg :down, KbUp do
#         actor.current_selected_index = max(actor.current_selected_index - 1, 0)
#       end
#       input_manager.reg :down, KbDown do
#         actor.current_selected_index = min(actor.current_selected_index + 1, menu_items.size - 1)
#       end
#       input_manager.reg :down, KbRight do
#         actor.player_count = min(actor.player_count + 1, 4) if actor.current_selected_index == 1
#       end
#       input_manager.reg :down, KbLeft do
#         actor.player_count = max(actor.player_count - 1, 1) if actor.current_selected_index == 1
#       end
#       input_manager.reg :down, KbReturn do
#         actor.emit :start, actor.player_count if actor.current_selected_index == 0
#       end
#       
#       menu_items.each.with_index do |item, i|
#         actor.menu_labels << stage.create_actor(:label, text: item, x: 900, y: 220, font_name: "vigilanc.ttf", font_size: 50, color: [222, 135, 170])
#       end
#       update_highlight
#       
#       # add background image
#       #stage.create_actor(:icon, image: "title_screen_reticle.png", x: 650, y: 350)
#       stage.create_actor(:icon, image: "title_screen.png", x: 670, y: 350)
#       
#       # add title for game on the menu screen
#       print_menu_header "Killbox", "a multi-player, same keyboard, action game."
# 
#       # add some help message for game on the menu screen
#       print_menu_help_text "Game Controls: A, move left. D, move right. W, look up. S, look down. V, shield. N, jump. M, bomb."
#     end
# 
#     helpers do
#       include MinMaxHelpers
# 
#       # TODO make an actual menu item class that can respond to key presses..
#       # ie: left, right, enter
#       def menu_items
#         [ "Start",
#           "Players: #{actor.player_count}"
#         ]
#       end
# 
#       def update_highlight
#         y = actor.y
#         actor.menu_labels.each.with_index do |label, i|
#           label.font_size = i == actor.current_selected_index ? 70 : 50
#           label.y = y
#           label.text = menu_items[i]
# 
#           y += label.font_size
#         end
# 
#       end
#       
#       def print_menu_header(title, sub_title)
#         print_menu_text(title, 100, 900, 10, [160, 44, 90])
#         print_menu_text(sub_title, 28, 760, 120)
#       end
# 
#       def print_menu_help_text(text)
#         print_menu_text(text, 28, 150, 700)
#       end
# 
#       def print_menu_text(text, size, x, y, color=[244, 215, 227])
#         actor.title_labels << stage.create_actor(:label, text: text, x: x, y: y, font_name: "vigilanc.ttf" , font_size: size, color: color)
#       end
#     end
#   end
# end

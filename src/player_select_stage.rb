
define_stage :player_select do

  curtain_up do |*args|
    create_actor(:icon, image: "title_screen.png", x: 670, y: 350)
    print_menu_header "Foxy", "a multi-player, same keyboard, action game."

    # add some help message for game on the menu screen
    print_menu_help_text "Game Controls: A, move left. D, move right. W, look up. S, look down. V, shield. N, jump. M, bomb."


    menu = create_actor :player_select_menu, x: 100, y: 30

    menu.when :start do |count|
      fire :next_stage, player_count: count
    end
    input_manager.reg :down, KbEscape do
      exit
    end
  end

  curtain_down do |*args|
    input_manager.clear_hooks
  end

  helpers do
    def print_menu_header(title, sub_title)
      print_menu_text(title, 100, 900, 10, [160, 44, 90])
      print_menu_text(sub_title, 28, 760, 120)
    end

    def print_menu_help_text(text)
      print_menu_text(text, 28, 150, 700)
    end

    def print_menu_text(text, size, x, y, color=[244, 215, 227])
      create_actor(:label, text: text, x: x, y: y, font_name: "vigilanc.ttf" , font_size: size, color: color)
    end
  end
end


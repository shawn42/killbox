
define_stage :player_select do

  curtain_up do |*args|
    create_actor(:icon, image: "title_screen.png", x: 670, y: 350)
    print_menu_header "Killbox", "a multi-player, same keyboard, action game."

    @player_select_menu = create_actor :player_select_menu, x: 100, y: 30

    @player_select_menu.when :selected do |value|
      if value == :setup_controls
        fire :change_stage, :control_setup
      else
        fire :next_stage, player_count: value
      end
    end

    input_manager.reg :down, KbEscape do
      exit
    end
  end

  curtain_down do |*args|
    @player_select_menu.unsubscribe_all self
    input_manager.clear_hooks
  end

  helpers do
    def print_menu_header(title, sub_title)
      print_menu_text(title, 100, 900, 10, [160, 44, 90])
      print_menu_text(sub_title, 28, 760, 120)
    end

    def print_menu_text(text, size, x, y, color=[244, 215, 227])
      create_actor(:label, text: text, x: x, y: y, font_size: size, color: color)
    end
  end
end


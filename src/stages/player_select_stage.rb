define_stage :player_select do

  curtain_up do |*args|
    res_x, res_y = config_manager[:screen_resolution]

    x_sc = res_x.to_f/1280
    y_sc = res_y.to_f/720
    scale = x_sc < y_sc ? x_sc : y_sc
    create_actor(:icon, image: "title_screen.png", x: res_x/2, y: res_y/2, x_scale: scale, y_scale: scale)

    print_menu_header "Killbox", "a multi-player, same keyboard, action game."

    x_pos = res_x/2
    y_pos = res_y * 7.5/10
    @player_select_menu = create_actor :player_select_menu, x: x_pos, y: y_pos

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
      res_x, res_y = config_manager[:screen_resolution]

      title_size = res_y/4
      title_x = res_x/2
      title_y = res_y/100

      subtitle_size = res_y/25
      subtitle_x = title_x
      subtitle_y = res_y/100 + title_y + (title_size * 9/10)

      print_menu_text(title, title_size, title_x, title_y, [160, 44, 90])
      print_menu_text(sub_title, subtitle_size, subtitle_x, subtitle_y)
    end

    def print_menu_text(text, size, x, y, color=[244, 215, 227])
      create_actor(:label, text: text, x: x, y: y, font_size: size, color: color)
    end
  end
end


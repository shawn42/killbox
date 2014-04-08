# Actor.definitions.delete :label
# Behavior.definitions.delete :label
# ActorView.definitions.delete :label_view

define_stage :player_select do
  requires :menu_builder, :viewport

  curtain_up do |*args|
    res_x, res_y = config_manager[:screen_resolution]

    x_sc = res_x.to_f/1280
    y_sc = res_y.to_f/720
    scale = x_sc < y_sc ? x_sc : y_sc
    create_actor(:icon, image: "title_screen.png", x: res_x/2, y: res_y/2, x_scale: scale, y_scale: scale)

    print_menu_header "Killbox", "a multiplayer, same keyboard, action game."

    x_pos = res_x/2
    y_pos = res_y * 7.5/10

    args = {
      name: "player_select",
      x: 1,
      y: 1,
      w: viewport.width,
      h: viewport.height,
      root: true,
      submenus: [],
    }

    font_size = 80
    label_x = x_pos

    label_opts = {
      y: y_pos,
      font_size: font_size,
      w: font_size,
      h: font_size,
      color: Colors.pink,
      border: {
        selected: {
          color: Colors.pink,
        },
      },
    }

    menu_width = 80
    player_menus = (1..4).map do |i|
      player_menu_args = label_opts.merge(value: i, 
                              label_text: i, 
                              x: x_pos + (i-1) * menu_width, 
                              name: "select_#{i}_player")

      # create_actor(:done_on_activate_menu, player_menu_args).tap do |player_menu|
      create_actor(:menu, player_menu_args).tap do |player_menu|
        player_menu.when(:activated) { next_stage(player_menu.value) }
      end

      controls_menu_args = label_opts.merge(value: :setup_controls, 
                              label_text: "Controls", 
                              y: 900,
                              x: x_pos,
                              w: 200, # todo can you look up font size here?
                              name: "controls_menu")
      create_actor(:menu, controls_menu_args).tap do |controls_menu|
        controls_menu.when(:activated) { control_setup }
      end

    end

    args[:submenus] = player_menus

    @player_select_menu = menu_builder.build(args)
    @player_select_menu.react_to :select_item, player_menus[1]

    input_manager.reg :down, Kb1 do next_stage 1 end
    input_manager.reg :down, Kb2 do next_stage 2 end
    input_manager.reg :down, Kb3 do next_stage 3 end
    input_manager.reg :down, Kb4 do next_stage 4 end

    input_manager.reg :down, KbC do setup_controls end
    input_manager.reg :down, KbEscape do
      exit
    end

  end

  curtain_down do |*args|
    @player_select_menu.unsubscribe_all self
    input_manager.clear_hooks
  end

  helpers do
    def setup_controls
      fire :change_stage, :control_setup
    end
    def next_stage(player_count)
      fire :next_stage, player_count: player_count
    end
    
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


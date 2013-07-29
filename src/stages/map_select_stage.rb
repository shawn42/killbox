
define_stage :map_select do

  curtain_up do |*args|
    opts = args.first || {}

    create_actor(:icon, image: "title_screen.png", x: 670, y: 350)
    print_menu_text("Select Map", 100, 100, 10, [160, 44, 90])

    menu = create_actor :map_select_menu, x: 100, y: 30

    menu.when :start do |map|
      backstage[:player_count] = opts[:player_count] if opts.has_key?(:player_count)
      backstage[:level_name] = map
      fire :next_stage
    end
    input_manager.reg :down, KbEscape do
      fire :change_stage, :player_select
    end
  end

  curtain_down do |*args|
    input_manager.clear_hooks
  end

  helpers do
    def print_menu_text(text, size, x, y, color=[244, 215, 227])
      create_actor(:label, text: text, x: x, y: y, font_name: "vigilanc.ttf" , font_size: size, color: color)
    end
  end
end


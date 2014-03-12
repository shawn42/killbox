
define_stage :control_setup do
  requires :player_control_menu_builder

  curtain_up do |*args|

    create_actor(:icon, image: "title_screen.png", x: 670, y: 350)
    # create_actor(:label, text: "Controls", font_size: 100, x: 900, y: 10)

    # not sure where this comes from
    # data_tree = backstage[:control_data_tree]
    @control_menu = player_control_menu_builder.build(input_manager)#, data_tree)
    # @player_control_builder = create_actor :player_control_builder, x: 100, y: 30

    # input_manager.reg :down, KbEscape do
    #   go_back
    # end
  end

  helpers do
    def go_back
      fire :change_stage, :player_select
    end
  end

  curtain_down do |*args|
    input_manager.clear_hooks
  end
end


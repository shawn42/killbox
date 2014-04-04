class MenuBuilder
  construct_with :stage, :viewport, :input_manager

  def build(args)
    menu = build_menu(args)
    for submenu in args[:submenus]
      menu.react_to :add_menu_item, submenu
    end
    menu.react_to :select_first_item

    menu
  end

  private
  def build_menu(args)
    menu = stage.create_actor :menu, args
      # name: args[:name],
      # x: args[:x] || 1,
      # y: args[:y] || 1, 
      # w: args[:w], 
      # h: args[:h],
      # root: !!args[:root]
    all_ups = [KbUp, Gp0Up, Gp1Up, Gp2Up, Gp3Up]
    all_downs = [KbDown, Gp0Down, Gp1Down, Gp2Down, Gp3Down]
    all_lefts = [KbLeft, Gp0Left, Gp1Left, Gp2Left, Gp3Left]
    all_rights = [KbRight, Gp0Right, Gp1Right, Gp2Right, Gp3Right]
    all_triggers = [KbReturn, KbEnter, Gp0Button1, Gp1Button1, Gp2Button1, Gp3Button1]
    all_backs = [KbEscape, Gp0Button0, Gp1Button0, Gp2Button0, Gp3Button0]

    input_manager.reg :down, *all_triggers do |evt|
      menu.react_to :trigger
    end
    input_manager.reg :down, *all_backs do |evt|
      menu.react_to :leave
    end
    input_manager.reg :down, *all_downs do |evt|
      menu.react_to :select_down_neighbor
    end
    input_manager.reg :down, *all_ups do |evt|
      menu.react_to :select_up_neighbor
    end
    input_manager.reg :down, *all_lefts do |evt|
      menu.react_to :select_left_neighbor
    end
    input_manager.reg :down, *all_rights do |evt|
      menu.react_to :select_right_neighbor
    end
    input_manager.reg :down do |evt|
      menu.react_to(BUTTON_ID_TO_SYM[evt[:id]])
    end

    menu
  end
end

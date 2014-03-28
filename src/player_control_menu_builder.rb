define_behavior :mmenu do
  requires :viewport

  setup do
    actor.has_attributes menu_items: [], active_item: nil, selected_item: nil,
      root: false

  end

  remove do
    actor.menu_items.each do |item|
      item.unsubscribe_all self
    end
  end

  helpers do
    def react_to(name, *args)
      if actor.active_item?
        puts "forwarding to active item: #{name} #{actor.active_item.name}"
        actor.active_item.react_to name, *args
      else
        puts "handling: #{name} #{actor.name}"
        send(name, *args) if respond_to? name
      end
    end

    def trigger
      log "trigger"
      select_first_item unless actor.selected_item
      selected_item = actor.selected_item
      if selected_item
        selected_item.react_to :activate 
        selected_item.react_to :deselect 
        actor.active_item = selected_item
      end
    end

    def select_upper_neighbor
      # keep in mind there is an y_offset on viewport (should be zero unless
      # we are scrolling around)
      bottom_edge = viewport.height

      items = actor.menu_items
      current_item = actor.selected_item

      up_neighbors = actor.menu_items.select{|n| n.y < current_item.y}
      closest = closest_neighbor(current_item, up_neighbors) ||
                closest_neighbor(vec2(current_item.x, bottom_edge), items)

      select_item closest
    end

    def select_lower_neighbor
      upper_edge = 0

      items = actor.menu_items
      current_item = actor.selected_item

      down_neighbors = actor.menu_items.select{|n| n.y > current_item.y}
      closest = closest_neighbor(current_item, down_neighbors) ||
                closest_neighbor(vec2(current_item.x, upper_edge), items)

      select_item closest
    end

    def select_left_neighbor
      # keep in mind there is an x_offset on viewport (should be zero unless
      # we are scrolling around)
      right_edge = viewport.width

      items = actor.menu_items
      current_item = actor.selected_item

      left_neighbors = actor.menu_items.select{|n| n.x < current_item.x}
      closest = closest_neighbor(current_item, left_neighbors) ||
                closest_neighbor(vec2(right_edge, current_item.y), items)

      select_item closest
    end

    def select_right_neighbor
      left_edge = 0

      items = actor.menu_items
      current_item = actor.selected_item

      right_neighbors = items.select{|n| n.x > current_item.x}
      closest = closest_neighbor(current_item, right_neighbors) ||
                closest_neighbor(vec2(left_edge, current_item.y), items)

      select_item closest
    end

    def closest_neighbor(item, neighbors)
      neighbors.sort_by do |n|
        dist_squared n.x, n.y, item.x, item.y
      end.first
    end

    def select_item(item)
      actor.selected_item.react_to :deselect
      actor.selected_item = item
      actor.selected_item.react_to :select
    end

    def dist_squared(x1, y1, x2, y2)
      x_diff = x1 - x2
      y_diff = y1 - y2
      x_diff**2 + y_diff**2
    end

    def leave
      actor.active_item.react_to :deactivate if actor.active_item
      actor.active_item = nil
      actor.selected_item.react_to :deselect if actor.selected_item
      actor.selected_item = nil
      actor.emit :done
    end

    def activate
      select_first_item
    end

    def add_menu_item(menu_item)
      menu_item.when :done do
        log "DEACTIVATING"
        menu_item.react_to :deactivate
        actor.active_item = nil
        if actor.root
          menu_item.react_to :select
          actor.selected_item = menu_item 
        end
      end
      actor.menu_items << menu_item
    end

    def select_first_item
      first_submenu = actor.menu_items.first
      if first_submenu
        actor.selected_item = first_submenu
        first_submenu.react_to :select 
      end
    end

  end
end

define_actor :device_detector do
  has_behaviors do
    selectable
  end

  behavior do
    setup do
      actor.has_attributes path: nil, input_id: nil
    end

    helpers do
      def react_to(name, *args)
        # KbRangeBegin # KbRangeEnd # MsRangeBegin # MsRangeEnd # GpRangeBegin # GpRangeEnd 
        id = BUTTON_SYM_TO_ID[name]

        if keyboard?(id) || gamepad?(id)
          log "device_detector picked up: #{name}"
          actor.input_id = id
          actor.emit :path_value_changed, actor.path, actor.input_id
          actor.emit :done
        end
      end

      def keyboard?(id)
        (KbRangeBegin..KbRangeEnd).include?(id)
      end

      def gamepad?(id)
        (GpRangeBegin..GpRangeEnd).include?(id)
      end
    end
      
  end
end

define_actor :mmenu do
  has_behaviors do
    positioned
    sized
    labeled
    selectable
    mmenu
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
          color = Color::RED
          width = 4
        elsif actor.active?
          color = Color::GREEN
          width = 4
        end

        color = color || Color::WHITE
        width = width || 1
        [*0..width-1].to_a.each do |offset|
          target.draw_box x + offset, y + offset, x + w - offset, y + h - offset, color, z
        end
      end
    end
  end
end


define_behavior :labeled do
  requires :stage

  setup do
    actor.has_attributes label_text: "", label: nil
    label_attributes = actor.attributes.dup
    label_attributes.delete :view
    actor.label = stage.create_actor :label, label_attributes
    actor.when :label_text_changed do |old_label, new_label|
      actor.label.text = new_label
    end
    actor.label.text = actor.label_text
  end

  remove do
    actor.label.remove
  end
end

define_behavior :sized do
  setup do
    actor.has_attributes w: 100, h: 80
  end
end

define_behavior :selectable do
  setup do
    actor.has_attributes selected: false, active: false
    reacts_with :select, :deselect, :activate, :deactivate
  end

  helpers do
    def select
      actor.selected = true
    end
    def deselect
      actor.selected = false
    end
    def activate
      actor.active = true
    end
    def deactivate
      actor.active = false
    end
  end
end


class PlayerControlMenuBuilder
  construct_with :stage, :viewport, :input_manager

  def controls
    return @controls if @controls
    controls_hash = {
      player1: {
        current_device: :gamepad,

        devices: {
          gamepad: {
            left: :gp0_left,
            right: :gp0_right,
            up: :gp0_up,
            down: :gp0_down,

            shoot: :gp0_button_0,
            jump: :gp0_button_1,
            bomb: :gp0_button_2,
            shield: :gp0_button_3,
          },

          keyboard: {
            left: :a,
            right: :d,
            up: :w,
            down: :s,

            shoot: :b,
            jump: :n,
            bomb: :m,
            shield: :v,
          }
        }
      },

      player2: {
        current_device: :gamepad,

        devices: {
          gamepad: {
            left: :gp1_left,
            right: :gp1_right,
            up: :gp1_up,
            down: :gp1_down,

            shoot: :gp1_button_0,
            jump: :gp1_button_1,
            bomb: :gp1_button_2,
            shield: :gp1_button_3,
          },

          keyboard: {
            left: :f,
            right: :h,
            up: :t,
            down: :g,

            shoot: :i,
            jump: :o,
            bomb: :p,
            shield: :u,
          }
        }
      }
    }

    @controls = HashTree.new controls_hash
  end

  def half_viewport_width; viewport.width / 2; end
  def half_viewport_height; viewport.height / 2; end

  def build_player_controls_selection_menu
    player_controls_menu = stage.create_actor :mmenu, 
      name: "main_menu",
      x: 1, y: 1, 
      w: viewport.width, 
      h: viewport.height,
      root: true

    input_manager.reg :down, KbF1 do |evt|
      player_controls_menu.react_to :select_first_item
    end
    input_manager.reg :down, KbReturn do |evt|
      player_controls_menu.react_to :trigger
    end
    input_manager.reg :down, KbEscape do |evt|
      player_controls_menu.react_to :leave
    end
    input_manager.reg :down, KbDown do |evt|
      player_controls_menu.react_to :select_lower_neighbor
    end
    input_manager.reg :down, KbUp do |evt|
      player_controls_menu.react_to :select_upper_neighbor
    end
    input_manager.reg :down, KbLeft do |evt|
      player_controls_menu.react_to :select_left_neighbor
    end
    input_manager.reg :down, KbRight do |evt|
      player_controls_menu.react_to :select_right_neighbor
    end
    input_manager.reg :down do |evt|
      player_controls_menu.react_to(BUTTON_ID_TO_SYM[evt[:id]])
    end

    player_controls_menu
  end

  def build_player_control_setup_menu(opts)
    player_number = opts[:player]
    menu_opts = {
      w: half_viewport_width, 
      h: half_viewport_height, 
      x: (half_viewport_width*(player_number-1)) % viewport.width,
      y: player_number > 2 ? half_viewport_height : 0,
      name: "player#{player_number}_menu",
      label_text: "player#{player_number}_menu"
    }
    log menu_opts
    stage.create_actor :mmenu, menu_opts

  end

  def build(controls_data) # controls)

    # ---------
    player_controls_menu = build_player_controls_selection_menu

    p1_control_menu = build_player_control_setup_menu player: 1
    p2_control_menu = build_player_control_setup_menu player: 2
    p3_control_menu = build_player_control_setup_menu player: 3
    p4_control_menu = build_player_control_setup_menu player: 4

    player_controls_menu.react_to :add_menu_item, p1_control_menu
    player_controls_menu.react_to :add_menu_item, p2_control_menu
    player_controls_menu.react_to :add_menu_item, p3_control_menu
    player_controls_menu.react_to :add_menu_item, p4_control_menu

    player_controls_menu.react_to :select_first_item
    # ---------

    # device_selection_menu = stage.create_actor :mmenu, label_text: "Input Device",
    #   x: player_controls_menu.x+5, y: player_controls_menu.y+player_controls_menu.h-30, h: 30, w: 300 

    # control_setting_menu = stage.create_actor :mmenu, label_text: "Other",
    #   x: player_controls_menu.x+5, y: player_controls_menu.y+player_controls_menu.h-70, h: 30, w: 300 

    # device_detector = stage.create_actor :device_detector, path: [:player1, :devices, :gamepad, :jump], input_id: :m

    # player_controls_menu.react_to :add_menu_item, device_selection_menu
    # player_controls_menu.react_to :add_menu_item, control_setting_menu
    # device_selection_menu.react_to :add_menu_item, device_detector

    # device_selection_menu.when :path_value_changed do |*args|
    #   path, id = args
    #   controls_data.set_value_for_path(id, path)
    #   log "PATH CHANGED #{args}"
    #   log controls_data
    # end

    player_controls_menu
  end

end

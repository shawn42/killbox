define_behavior :menu do
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

    def select_up_neighbor
      close_sort = ->(item){ item.y < actor.selected_item.y }
      fallback_point = vec2(actor.selected_item.x, viewport.height)
      smart_select_neighbor(close_sort, fallback_point)
    end

    def select_right_neighbor
      close_sort = ->(item){ item.x > actor.selected_item.x }
      fallback_point = vec2(0, actor.selected_item.y)
      smart_select_neighbor(close_sort, fallback_point)
    end

    def select_down_neighbor
      close_sort = ->(item){ item.y > actor.selected_item.y }
      fallback_point = vec2(actor.selected_item.x, 0)
      smart_select_neighbor(close_sort, fallback_point)
    end

    def select_left_neighbor
      close_sort = ->(item){ item.x < actor.selected_item.x }
      fallback_point = vec2(viewport.width, actor.selected_item.y)
      smart_select_neighbor(close_sort, fallback_point)
    end

    def smart_select_neighbor(direction_sort, fallback_point)
      directional_neighbors = actor.menu_items.select { |item| direction_sort.call(item) }
      puts "FINDING..."
      closest = closest_neighbor(actor.selected_item, directional_neighbors) ||
                closest_neighbor(fallback_point, actor.menu_items)

      select_item closest
    end

    def select_item(item)
      actor.selected_item.react_to :deselect
      actor.selected_item = item
      actor.selected_item.react_to :select
    end

    def closest_neighbor(target_point, items)
      items.sort_by do |item|
        dist_squared item, target_point
      end.first
    end

    def dist_squared(first, second)
      x_diff = first.x - second.x
      y_diff = first.y - second.y
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

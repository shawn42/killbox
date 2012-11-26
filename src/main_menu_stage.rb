define_stage :main_menu do

  setup do
    menu = create_actor :menu, x: 300, y: 200

    menu.when :start do |player_count|
      log "MENU STARTING"
      fire :next_stage, player_count: player_count
    end
  end

  helpers do
    def curtain_down(*args)
      log "band-aid til gamebox gets updated"
      input_manager.clear_hooks
    end
  end
end


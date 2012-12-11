define_stage :main_menu do

  curtain_up do |*args|
    menu = create_actor :menu, x: 300, y: 200

    menu.when :start do |player_count|
      fire :next_stage, player_count: player_count
    end
  end

  curtain_down do |*args|
    log "band-aid til gamebox gets updated"
    input_manager.clear_hooks
  end
end


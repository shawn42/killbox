define_stage :score do

  setup do

    x = 400
    y = 300

    4.times do |i|
      score = backstage[:scores][i+1] || 0
      label = create_actor :label, x: x, y: y, text: "P#{i+1}: #{score}", font_size: 70
      y += label.font_size * 1.5
    end

    input_manager.reg :down do
      fire :change_stage, :level_play
    end
  end

  helpers do
    def curtain_down(*args)
      log "band-aid til gamebox gets updated"
      input_manager.clear_hooks
    end
  end
end


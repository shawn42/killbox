define_stage :score do

  curtain_up do |*args|
    # add background image
    create_actor :icon, image: "score_screen.png", x: 670, y: 350
    
    # add labels
    x = 100
    y = 200
    
    create_actor :label, x: x, y: 50, text: "Score", font_size: 100, font_name: "vigilanc.ttf", color: [160, 44, 90]

    4.times do |i|
      score = backstage[:scores][i+1] || 0
      label = create_actor :label, x: x, y: y, text: "Player #{i+1}: #{score}", font_size: 70, font_name: "vigilanc.ttf"
      y += label.font_size * 1.2
    end

    input_manager.reg :down do
      fire :change_stage, :map_select
    end
  end

  curtain_down do |*args|
    log "band-aid til gamebox gets updated"
    input_manager.clear_hooks
  end
end

